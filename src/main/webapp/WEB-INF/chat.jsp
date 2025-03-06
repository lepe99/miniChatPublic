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
    <style>
        body * {
            font-family: Jua;
        }

        .sphoto {
            width: 40px;
            height: 40px;
            border-radius: 20px;
        }

        .profile {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .frame {
            display: flex;
            flex-direction: column; /* 상단(top)과 나머지 부분을 세로 정렬 */
            height: 100vh;
            padding: 30px;
        }

        /* 상단 박스 */
        .top {
            display: flex;
            height: 50px;
            border-radius: 18px;
            margin-bottom: 15px;
            background-color: #dcdcdc;
            align-items: center; /* 수직 가운데 정렬 */
            position: relative;
        }

        .popoverbtn {
            display: flex;
            margin-left: auto;
            align-items: center;
            cursor: pointer;
            text-decoration: none;
            color: black;
        }

        /* 아래 영역을 가로 배치 */
        .chat {
            display: flex;
            flex: 1; /* 남은 공간을 모두 차지 */
        }

        /* 왼쪽 유저 목록 */
        .left {
            width: 15%; /* 전체 화면의 15% 차지 */
            min-width: 200px; /* 최소 너비 */
            background-color: #dcdcdc;
            color: white;
            border-radius: 20px;
            align-items: center;
            padding: 20px;
            display: flex;
            flex-direction: column; /* 내부 요소를 세로 정렬 */
            margin-right: 15px;
        }

        /* 오른쪽 채팅 영역 */
        .right {
            flex: 1; /* 남은 공간을 모두 차지 */
            background-color: #dcdcdc;
            display: flex;
            flex-direction: column;
        }

        .chatbox {
            flex: 1;
            flex-direction: column-reverse;
            padding: 10px;
            display: flex;
            min-height: 300px; /* 최소 높이 설정 */
            overflow-y: auto; /* 스크롤 가능하도록 */
            background-color: white; /* 배경색 설정 */
        }

        .chatinput {
            display: flex;
            border-top: 1px solid #ccc;
            padding: 5px;
        }

        .chatinput input {
            flex: 1;
            padding: 5px;
            border: none;
            outline: none;
        }

        .chatinput button {
            padding: 5px 10px;
            border: none;
            background: #007bff;
            color: white;
            cursor: pointer;
        }

        .chatmsg {
            display: block !important;
            align-items: center;
            color: black;
            margin: 5px 0;
        }

        .mymsg {
            justify-content: flex-end;
            background-color: #dcf8c6;
            padding: 10px;
            border-radius: 10px;
        }

        .othermsg {
            justify-content: flex-start;
            background-color: #f1f0f0;
            padding: 10px;
            border-radius: 10px;
        }

        .msgbubble {
            min-height: 20px; /* 최소 높이를 설정하여 보이도록 함 */
            height: 30px;
            display: inline-block; /* 혹시 모를 flex 문제 방지 */
            padding: 10px; /* 내부 패딩 추가 */
            background-color: lightgray; /* 메시지 확인용 배경색 */
            border-radius: 10px;
        }

        .timestamp {
            display: inline-block !important; /* 강제로 보이게 설정 */
            font-size: 12px;
            color: gray;
        }
    </style>
    <script>
        $(function () {

            // 로그인 여부 확인
            let isLogin = "${sessionScope.isLogin}"; // 로그인 됐으면 true
            if (!isLogin) {
                location.href = '/login';
            }

            //popover a태그 기본방지
            document.querySelectorAll('.popoverbtn').forEach(function (el) {
                el.addEventListener("click", function (e) {
                    e.preventDefault();
                });
            });

            //button popover
            document.querySelectorAll('.popoverbtn').forEach(function (el) {
                new bootstrap.Popover(el, {
                    html: true,
                    container: 'body', //popover가 body에 추가될수있게
                    sanitize: false,    //html정상렌더링
                    content: "<button class='btn btn-danger btn-sm' onclick='location.href=\"/logout\"'>로그아웃</button>"
                });
            });

            //채팅기능
            const chatBox = $("#chatBox");
            const messageInput = $("#messageInput");
            const sendButton = $("#sendButton");

            //버튼 클릭시 메세지 전송
            sendButton.click(function () {
                let message = messageInput.val().trim();
                if (message !== "") {
                    sendMessage(true, "", "", message); //내 메세지 추가
                    messageInput.val(""); //입력창 초기화
                }
            });

            //엔터 키 입력시 메세지 전송
            messageInput.keypress(function (event) {
                if (event.which === 13) {    //Enter 아스키
                    sendButton.click();
                }
            });



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

        //메세지 전송 함수
        function sendMessage(isMine, profileImage, nickname, message) {
            // console.log("sendMessage 호출됨"); // ✅ 함수가 실행되는지 확인
            // console.log("메시지 내용:", message);

            let timestamp = new Date().toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});
            // console.log("📩 timestamp 값:", timestamp);

            let messageHtml;
            if (isMine) {
                //내메세지 (오른쪽정렬, 타임스탬프가 왼쪽에 표시)
                messageHtml = `
                    <div class="chatmsg mymsg">
                        <span class="timestamp">\${timestamp}</span>
                        <div class="msgbubble">\${message}</div>
                    </div>
                    `;
            } else {
                //상대방메세지 (왼쪽정렬, 프로필+닉네임 표시 , 타임스탬프 오른쪽)
                messageHtml = `
                    <div class="chatmsg othermsg">
                        <div class="prifilecontainer">
                            <img src="\${profileImage}" class="profileImg">
                            <span class="nickname">\${nickname}</span>
                        </div>
                        <div class="msgcontainer">
                            <div class="msgbubble">\${message}</div>
                            <span class="timestamp">\${timestamp}</span>
                        </div>
                    </div>
                    `;
            }
            // console.log("추가할 HTML:", messageHtml); // ✅ HTML 코드 확인
            chatBox.append(messageHtml);
            // console.log("현재 chatBox 내용:", chatBox.html()); // ✅ chatBox에 추가되었는지 확인
            chatBox.scrollTop(chatBox.prop("scrollHeight")); // 스크롤 아래로 이동
        }

        // 유저 리스트 출력
        function displayUserList(userList) {
            let userListHtml = "";
            $("#left").empty(); // 기존 유저 리스트 삭제
            userList.forEach((user) => {
                userListHtml += `
                <div class="profile">
                    <img src="\${user.profileImage}" class="sphoto">
                    <span class="nickname">\${user.nickname}</span>
                </div>
                `;
                console.log(userListHtml);
            });
            $(".left").html(userListHtml);
        }

        // 메세지 출력
        function displayMessage(message) {
            console.log("메세지 출력");
        }
    </script>
</head>
<body>
<div class="frame">
    <div class="top">
        <span>채팅창</span>
        <a href="#" title="Header" data-bs-toggle="popover" data-bs-placement="bottom"
           class="popoverbtn">
            <img src="${sessionScope.profileImage}" class="sphoto">&nbsp;${sessionScope.nickname}님, 안녕하세요!
        </a>
    </div>
    <div class="chat">
        <div class="left">
            <div class="input-group profile">
                <img src="${sessionScope.profileImage}" class="sphoto">&nbsp;${sessionScope.nickname}
            </div>
            <br>
        </div>
        <div class="right">
            <!-- 채팅 메세지가 표시되는 영역 -->
            <div class="chatbox" id="chatBox">

            </div>
            <!-- 채팅 입력창 -->
            <div class="chatinput">
                <input type="text" id="messageInput" placeholder="메세지를 입력하세요..."/>
                <button id="sendButton">전송</button>
            </div>
        </div>
    </div>
</div>
</body>
</html>