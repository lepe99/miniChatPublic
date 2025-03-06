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
    console.log("유저 리스트 출력");
}

// 메세지 출력
function displayMessage(message) {
    console.log("메세지 출력");
}