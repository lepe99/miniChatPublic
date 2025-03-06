// chat.jsp 페이지로 옮길 스크립트


$(function () {

    sendButton.click(function () {
        let message = {
            nickname: "${sessionScope.nickname}",
            profileImage: "${sessionScope.profileImage}",
            content: $("#messageInput").val()
        };
        // 메세지 전송
        socket.send(JSON.stringify(message));

        // db에 저장
        $.ajax({
            url: "insert",
            type: "post",
            data: {content: $("#messageInput").val()},
            success: (response) => {
                if (response === "success") {
                    console.log("메세지 저장 성공");
                } else {
                    console.log("메세지 저장 실패");
                }
            },
            error : (xhr, status, error) => {
                console.error("status: " + xhr.status);
                console.error("error: " + error);
            }
        })
        // 입력창 초기화
        $("#messageInput").val("");
    });
});