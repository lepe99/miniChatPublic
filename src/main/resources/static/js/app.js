// chat.jsp 페이지로 옮길 스크립트
$(function () {
    // url 에 넣을 세션 정보 받아오기
    const nickname = encodeURIComponent("${sessionScope.nickname}");
    const profileImage = encodeURIComponent("${sessionScope.profileImage}");
    // 웹소켓 연결, url에 세션 정보 포함하기
    let socket = new WebSocket("ws://localhost:8085/chat?nickname=" + nickname + "&profileImage=" + profileImage);

    // 웹소켓으로부터 메세지 수신
    socket.onmessage = (event) => {
        // 수신된 메세지를 JSON으로 파싱
        let message = JSON.parse(event.data);

        if (message.type === "enter") {
            // 입장 메세지 처리
            let userInfo = message.userInfo;
            console.log(userInfo.nickname + "님이 입장하셨습니다.");
        } else if (message.type === "leave") {
            // 퇴장 메세지 처리
            let userInfo = message.userInfo;
            console.log(userInfo.nickname + "님이 퇴장하셨습니다.");
        } else if (message.type === "userList") {
            // 유저 리스트 처리
            displayUserList(message.userList);
        } else {
            // 일반 메세지 처리
            displayMessage(message);
        }
    };

    // 전송 버튼 클릭 시
    $("#btnSend").click(() => {
        let message = {
            nickname: "${sessionScope.nickname}",
            profileImage: "${sessionScope.profileImage}",
            content: $("#inputMessage").val()
        };
        // 메세지 전송
        socket.send(JSON.stringify(message));
        // 입력창 초기화
        $("#inputMessage").val("");
    });

});

// 유저 리스트 출력
function displayUserList(userList) {
    let userListHtml = "";
    $("#left").empty(); // 기존 유저 리스트 삭제
    userList.forEach((user) => {
        userListHtml += `
                <div class="profile">
                    <img src="${user.profileImage}" class="profileImage">
                    <span class="nickname">${user.nickname}</span>
                </div>
        `;
        $("#left").append(userListHtml);
    });

}

// 메세지 출력
function displayMessage(message) {
    console.log("메세지 출력");
    let timestamp = new Date().toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'});

    let messageHtml = "";
    if (message.nickname === "${sessionScope.nickname}") {
        //내 메세지(오른쪽 하단 정렬, 프로필 닉네임 표시안하고 타임스탬프 왼쪽)
        messageHtml = `
                    <div class="mymessage">
                        <span class="timestamp">${timestamp}</span>
                        <div class="messagecontent">${message.content}</div>
                    </div>
                    `;
    } else {
        //상대방메세지 (왼쪽 하단 정렬, 프로필+닉네임 표시 , 타임스탬프 오른쪽)
        messageHtml = `
                    <div class="othermessage">
                        <div class="prifilecontainer">
                            <img src="${message.profileImage}" class="profileImg">
                            <span class="nickname">${message.nickname}</span>
                        </div>
                        <div class="messagecontainer">
                            <div class="messagecontent">${message.content}</div>
                            <span class="timestamp">${timestamp}</span>
                        </div>
                    </div>
                    `;
    }

    // console.log("추가할 HTML:", messageHtml); // ✅ HTML 코드 확인
    chatBox.append(messageHtml);
    // console.log("현재 chatBox 내용:", chatBox.html()); // ✅ chatBox에 추가되었는지 확인
    chatBox.scrollTop(chatBox.prop("scrollHeight")); // 스크롤 아래로 이동
}