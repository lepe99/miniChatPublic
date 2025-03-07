<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>502jsp study</title>
    <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@400..700&family=Gaegu&family=Jua&family=Nanum+Pen+Script&family=Playwrite+AU+SA:wght@100..400&family=Single+Day&display=swap"
          rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="css/chat.css">
    <script>
        let objectStorageUrl = "${objectStorageUrl}";
        let imageOptimizerFrontUrl = "${imageOptimizerFrontUrl}";
        let imageOptimizerBackUrl = "${imageOptimizerBackUrl}";

        // 로그인 여부 확인
        let isLogin = "${sessionScope.isLogin}"; // 로그인 됐으면 true
        if (!isLogin) {
            location.href = '/login';
        }

        $(function () {

            let imagePopover = null;

            // + 버튼 선택시 파일선택
            $("#imageInputBtn").click(function (){
                $("#imageInput").click();
            });

            //파일 선택시 이미지 미리보기 생성 (popover)
            $("#imageInput").change(function (event){
                let file= event.target.files[0];

                if(file){
                    let reader = new FileReader();
                    reader.onload = function (e){
                        let imageInputHtml = `
                        <img src="\${e.target.result}" id="popoverImage">`;
                        //기존 Popover 제거(중복방지)
                        if(imagePopover){
                            imagePopover.dispose();
                            imagePopover=null;
                        }

                        //popover 생성 및 내용 업데이트
                        $("#imageInputBtn").attr("data-bs-content",imageInputHtml);
                        //새로초기화
                        imagePopover = new bootstrap.Popover($("#imageInputBtn")[0],{
                            html:true,
                            trigger:"manual",
                            placement:"top"
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

                // 세션이 만료되었을 경우 로그인 페이지 리다이렉트
                if (!isLogin) location.href = '/login';

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
                            nickname: "${sessionScope.nickname}",
                            profileImage: "${sessionScope.profileImage}",
                            content: messageInput.val(),
                            chatImage: response
                        };
                        // 웹소켓 메세지 전송
                        socket.send(JSON.stringify(message));

                        // 입력창 초기화
                        messageInput.val("");
                        $("#imageInput").val("");

                    },
                    error : (xhr, status, error) => {
                        console.error("status: " + xhr.status);
                        console.error("error: " + error);
                    }
                });

            });

            // url 에 넣을 세션 정보 받아오기
            const nickname = encodeURIComponent("${sessionScope.nickname}");
            const profileImage = encodeURIComponent("${sessionScope.profileImage}");
            const host = window.location.host;
            // 웹소켓 연결, url에 세션 정보 포함하기
            let socket = new WebSocket(`ws://\${host}/chat?nickname=\${nickname}&profileImage=\${profileImage}`);

            // 웹소켓으로부터 메세지 수신
            socket.onmessage = (event) => {
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

        });

        // 유저 리스트 출력
        function displayUserList(userList) {
            let userListHtml = "";
            $("#userList").empty(); // 기존 유저 리스트 삭제

            // 중복 제거를 위한 Map 선언
            const uniqueUserList = new Map();

            userList.forEach((user) => {
                const key = `\${user.nickname}-\${user.profileImage}`;
                uniqueUserList.set(key, user); // 중복 제거
            });

            // 인원수 표시
            userListHtml += `인원수 : \${uniqueUserList.size}명<hr>`;

            // 중복 제거된 유저 리스트로 다시 변환
            uniqueUserList.values().forEach(user => {
                userListHtml += `
                <div class="profile">
                    <img src="\${user.profileImage}" class="userProfileImage">
                    <span class="userNickname">\${user.nickname}</span>
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
            let time = timestamp.toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'});

            let messageHtml = "";

            if (lastDisplayedDate !== date) {
                // 날짜가 바뀌면 날짜 표시
                messageHtml = `
                    <div class="date">
                        <span>\${date}</span>
                    </div>
                    `;
                lastDisplayedDate = date; // 마지막 표시 날짜 갱신
            }
            if (message.nickname === "${sessionScope.nickname}") {
                //내 메세지(오른쪽 하단 정렬, 프로필 닉네임 표시안하고 타임스탬프 왼쪽)
                if (message.chatImage === "") {
                    messageHtml += `
                    <div class="myMessage">
                        <span class="timestamp">\${time}</span>
                        <div class="myContents">
                            \${message.content}
                        </div>
                    </div>
                    `;
                } else {
                    messageHtml += `
                    <div class="myMessage">
                        <span class="timestamp">\${time}</span>
                        <div class="myContents">
                            <img src="\${imageOptimizerFrontUrl}/images/\${message.chatImage}\${imageOptimizerBackUrl}"
                            class="chatImage" alt="\${message.chatImage}">
                            \${message.content}
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
                            <img src="\${message.profileImage}" class="chatProfileImage">
                            <span class="nickname">\${message.nickname}</span>
                        </div>
                        <div class="otherContents">
                            \${message.content}
                        </div>
                        <span class="timestamp">\${time}</span>
                    </div>
                    `;
                } else {
                    messageHtml += `
                    <div class="otherMessage">
                        <div class="otherChatProfile">
                            <img src="\${message.profileImage}" class="chatProfileImage">
                            <span class="nickname">\${message.nickname}</span>
                        </div>
                        <div class="otherContents">
                            <img src="\${imageOptimizerFrontUrl}/images/\${message.chatImage}\${imageOptimizerBackUrl}"
                            class="chatImage" alt="\${message.chatImage}">
                            \${message.content}
                        </div>
                        <span class="timestamp">\${time}</span>
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
        function displaySystemMessage (text){
            let messageHtml =`
            <div class="infoMessage">
                <span>\${text}</span>
            </div>
            `;
            $("#chatBox").append(messageHtml);
            $("#chatBox").scrollTop($("#chatBox")[0].scrollHeight); // 스크롤 아래로 자동 이동
        }


    </script>
</head>
<body>
<div id="chatContainer">
    <div id="header">
        <span>채팅창</span>
        <a href="#" title="Header" data-bs-toggle="popover" data-bs-placement="bottom"
           id="popoverBtn">
            <img src="${sessionScope.profileImage}" id="topImage">&nbsp;${sessionScope.nickname}님, 안녕하세요!
        </a>
    </div>
    <div id="main">
        <div id="userList">
            <br>
        </div>
        <div id="chat">
            <!-- 채팅 메세지가 표시되는 영역 -->
            <div id="chatBox">
                <c:forEach var="chat" items="${chatList}">
                    <script>
                        // java 객체 => javaScript 객체로 변환
                        message = {
                            nickname: "${chat.nickname}",
                            profileImage: "${chat.profileImage}",
                            content: "${chat.message}",
                            chatImage: "${chat.chatImage}"
                        };
                        timestamp = new Date(${chat.createdAt.time});

                        // 메세지 출력
                        displayMessage(message, timestamp);
                    </script>
                </c:forEach>

            </div>
            <!-- 채팅 입력창 -->
            <form id="chatInput">
                <button type="button" id="imageInputBtn" data-bs-toggle="popover" data-bs-placement="top"
                        tilte="이미지 미리보기">+</button>
                <input type="file" name="chatImage" id="imageInput" hidden/>
                <input type="text" name="message" id="messageInput" placeholder="메세지를 입력하세요"/>
                <button type="submit" id="sendBtn">전송</button>
            </form>
        </div>
    </div>

    <!-- bs5 toast -->
    <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1100">
        <div id="liveToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="1000">
            <div class="toast-header">
                <strong class="me-auto">알림</strong>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body">
                채팅을 입력해주세요.
            </div>
        </div>
    </div>
</div>
</body>
</html>