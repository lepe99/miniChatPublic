$(function () {

    let imagePopover = null;

    // + 버튼 선택시 파일선택
    $("#imageInputBtn").click(function () {
        $("#imageInput").click();
    });

    //파일 선택시 이미지 미리보기 생성 (popover)
    $("#imageInput").change(function (event) {
        let file = event.target.files[0];

        if (file) {
            let reader = new FileReader();
            reader.onload = function (e) {
                let imageInputHtml = `
                        <img src="${e.target.result}" id="popoverImage">`;
                //기존 Popover 제거(중복방지)
                if (imagePopover) {
                    imagePopover.dispose();
                    imagePopover = null;
                }

                //popover 생성 및 내용 업데이트
                $("#imageInputBtn").attr("data-bs-content", imageInputHtml);
                //새로초기화
                imagePopover = new bootstrap.Popover($("#imageInputBtn")[0], {
                    html: true,
                    trigger: "manual",
                    placement: "top"
                });
                imagePopover.show(); //popover 표시
            };
            reader.readAsDataURL(file);
        }
    });

    // **바깥 클릭 시 popover 닫기**
    $(document).on("click", function (event) {
        // popover가 열려 있고, 클릭한 요소가 popover 내부가 아니라면 닫기
        if (imagePopover && !$(event.target).closest("#imageInputBtn, .popover").length) {
            imagePopover.dispose();
            imagePopover = null;
        }
    });

    //이미지 클릭시 챗모달 띄우기
    $("#chatBox").on("click", ".chatImage", function (e) {
        let imageAlt = $(e.target).attr("alt");
        let imageUrl = `${objectStorageUrl}/images/${imageAlt}`;
        $("#modalImage").attr("src", imageUrl);

        let modal = $("#chatModal");
        modal.css("display", "flex"); // 모달 표시

        //애니메이션 적용
        requestAnimationFrame(() => {
            modal.addClass("show");
        });
    });

    //외부 클릭시 모달 닫기
    $("#chatModal").on("click", function (e) {
        if (!$(e.target).closest("#modalImage").length) {
            let modal = $("#chatModal");
            modal.removeClass("show");
            setTimeout(() => {
                modal.hide();
            }, 300);
        }
    });

    //외부 클릭시 popover 닫기
    // Popover 외부 클릭 시 닫기
    $(document).on("click", function (e) {
        if (!$(e.target).closest("#popoverBtn").length) {
            $("#popoverBtn").popover("hide");
        }
    });

    // popover a태그 기본방지
    document.querySelectorAll('#popoverBtn').forEach(function (el) {
        el.addEventListener("click", function (e) {
            e.preventDefault();
        });
    });

    //button popover
    document.querySelectorAll('#popoverBtn').forEach(function (el) {
        new bootstrap.Popover(el, {
            html: true,
            container: 'body', //popover가 body에 추가될수있게
            sanitize: false,    //html 정상렌더링
            content: "<button class='btn btn-danger btn-sm' onclick='location.href=\"/logout\"'>로그아웃</button>"
        });
    });


    //버튼 클릭시 메세지 전송
    $("#chatInput").submit((e) => {
        e.preventDefault();

        let messageInput = $("#messageInput");
        let imageInput = $("#imageInput");


        // messageInput 이 비어있으면 전송하지 않음
        if (messageInput.val().trim() === "" && imageInput.val().trim() === "") {
            // Toast 보여주기
            var toastEl = document.getElementById('liveToast');
            var toast = new bootstrap.Toast(toastEl);
            toast.show();

            return;
        }

        // formdata 가져오기
        let formData = new FormData($("#chatInput")[0]);

        // messageInput 값 미리 받아오기
        let messageInputValue = messageInput.val();

        // 입력창 초기화
        messageInput.val("");
        imageInput.val("");


        // db에 저장
        $.ajax({
            url: "insert",
            type: "post",
            data: formData,
            contentType: false,
            processData: false,
            success: (response) => {
                console.log("메세지 저장 성공");

                // 메세지 객체 생성
                let message = {
                    nickname: window.nickname,
                    profileImage: window.profileImage,
                    content: messageInputValue,
                    chatImage: response
                };
                // 웹소켓 메세지 전송
                socket.send(JSON.stringify(message));

            },
            error: (xhr, status, error) => {
                if (xhr.status === 401) {
                    alert("세션이 만료되었습니다. 로그인 페이지로 이동합니다.");
                    location.href = '/login';
                } else if (xhr.status === 413) { // 파일 크기 초과
                    alert("파일 크기는 10MB를 넘을 수 없습니다.");
                } else {
                    alert("오류 발생. 상태 코드 : " + xhr.status + ", 오류 메시지 : " + xhr.responseText);
                }
            }
        });

    });

    // url 에 넣을 세션 정보 받아오기
    const nickname = encodeURIComponent(`${window.nickname}`);
    const profileImage = encodeURIComponent(`${window.profileImage}`);
    const host = window.location.host;
    // 웹소켓 연결, url에 세션 정보 포함하기
    let socket = new WebSocket(`ws://${host}/chat?nickname=${nickname}&profileImage=${profileImage}`);

    let pingTimeout;
    const PING_INTERVAL = 30000; // 30초

    // 웹소켓으로부터 메세지 수신
    socket.onmessage = (event) => {
        // ping 메세지 응답
        if (event.data === "ping") {
            socket.send("pong");
            resetPingTimeout(); // 타이머 초기화
            return;
        }
        // 수신된 메세지를 JSON으로 파싱
        let message = JSON.parse(event.data);

        if (message.type === "enter") {
            // 입장 메세지 처리
            let userInfo = message.userInfo;
            displaySystemMessage(userInfo.nickname + "님이 입장하셨습니다.");
        } else if (message.type === "leave") {
            // 퇴장 메세지 처리
            let userInfo = message.userInfo;
            displaySystemMessage(userInfo.nickname + "님이 퇴장하셨습니다.");
        } else if (message.type === "userList") {
            // 유저 리스트 처리
            displayUserList(message.userList);
        } else {
            // 일반 메세지 처리
            displayMessage(message);
        }
    };

    socket.onopen = () => { // 연결 시 타이머 시작
        resetPingTimeout();
    }

    socket.onclose = () => { // 연결 종료 시 타이머 제거
        clearTimeout(pingTimeout);
    }

});

// ping 메세지 전송 받을 시 타이머 초기화 / 받지 못할 시 세션 해제
function resetPingTimeout() {
    clearTimeout(pingTimeout);
    pingTimeout = setTimeout(() => {
        // 세션 해제 요청 (서버에 알림)
        $.ajax({
            url: "/logout",
            type: "post",
            success: () => {
                alert("세션이 만료되었습니다. 로그인 페이지로 이동합니다.");
                location.href = '/login';
            },
            error: (xhr, status, error) => {
                alert("오류 발생. 상태 코드 : " + xhr.status);
            }
        });

    }, PING_INTERVAL * 2); // ping의 두배 간격으로 설정. 안정성을 높임.
}

// 유저 리스트 출력
function displayUserList(userList) {
    let userListHtml = "";
    $("#userList").empty(); // 기존 유저 리스트 삭제

    // 중복 제거를 위한 Map 선언
    const uniqueUserList = new Map();

    userList.forEach((user) => {
        const key = `${user.nickname}-${user.profileImage}`;
        uniqueUserList.set(key, user); // 중복 제거
    });

    // 인원수 표시
    userListHtml += `인원수 : ${uniqueUserList.size}명<hr>`;

    // 중복 제거된 유저 리스트로 다시 변환
    uniqueUserList.values().forEach(user => {
        userListHtml += `
                <div class="profile">
                    <img src="${user.profileImage}" class="userProfileImage">
                    <span class="userNickname">${user.nickname}</span>
                </div>
                `;
        // console.log(userListHtml);
    });
    $("#userList").html(userListHtml);
}


// 마지막 표시 날짜 추적 위한 전역변수 선언
let lastDisplayedDate = null;

// 메세지 출력
function displayMessage(message, timestamp = new Date()) {
    // console.log("메세지 출력");
    let date = timestamp.toLocaleDateString();
    let time = timestamp.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});

    let messageHtml = "";

    if (lastDisplayedDate !== date) {
        // 날짜가 바뀌면 날짜 표시
        messageHtml = `
                    <div class="date">
                        <span>${date}</span>
                    </div>
                    `;
        lastDisplayedDate = date; // 마지막 표시 날짜 갱신
    }
    if (message.nickname === window.nickname) {
        //내 메세지(오른쪽 하단 정렬, 프로필 닉네임 표시안하고 타임스탬프 왼쪽)
        if (message.chatImage === "") {
            messageHtml += `
                    <div class="myMessage">
                        <span class="timestamp myTimestamp">${time}</span>
                        <div class="myContents">
                            ${message.content}
                        </div>
                    </div>
                    `;
        } else {
            messageHtml += `
                    <div class="myMessage">
                        <span class="timestamp myTimestamp">${time}</span>
                        <div class="myContents">
                            <img src="${imageOptimizerFrontUrl}/images/${message.chatImage}${imageOptimizerBackUrl}"
                            class="chatImage" alt="${message.chatImage}"><br>
                            ${message.content}
                        </div>
                    </div>
                    `;
        }
    } else {
        //상대방메세지 (왼쪽 하단 정렬, 프로필+닉네임 표시 , 타임스탬프 오른쪽)
        if (message.chatImage === "") {
            messageHtml += `
                    <div class="otherMessage">
                        <div class="otherChatProfile">
                            <img src="${message.profileImage}" class="chatProfileImage">
                            <span class="nickname">${message.nickname}</span>
                        </div>
                        <div class="otherContents">
                            ${message.content}
                        </div>
                        <span class="timestamp otherTimestamp">${time}</span>
                    </div>
                    `;
        } else {
            messageHtml += `
                    <div class="otherMessage">
                        <div class="otherChatProfile">
                            <img src="${message.profileImage}" class="chatProfileImage">
                            <span class="nickname">${message.nickname}</span>
                        </div>
                        <div class="otherContents">
                            <img src="${imageOptimizerFrontUrl}/images/${message.chatImage}${imageOptimizerBackUrl}"
                            class="chatImage" alt="${message.chatImage}"><br>
                            ${message.content}
                        </div>
                        <span class="timestamp otherTimestamp">${time}</span>
                    </div>
                    `;
        }
    }

    // console.log("추가할 HTML:", messageHtml); // ✅ HTML 코드 확인
    $("#chatBox").append(messageHtml);
    // console.log("현재 chatBox 내용:", chatBox.html()); // ✅ chatBox에 추가되었는지 확인
    // 스크롤 아래로 이동
    $("#chatBox").scrollTop($("#chatBox").prop("scrollHeight"));
}

//입퇴장 메세지 출력
function displaySystemMessage(text) {
    let messageHtml = `
            <div class="infoMessage">
                <span>${text}</span>
            </div>
            `;
    $("#chatBox").append(messageHtml);
    $("#chatBox").scrollTop($("#chatBox")[0].scrollHeight); // 스크롤 아래로 자동 이동
}
