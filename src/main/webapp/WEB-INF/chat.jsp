<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BitSync 502</title>
    <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@400..700&family=Gaegu&family=Jua&family=Nanum+Pen+Script&family=Playwrite+AU+SA:wght@100..400&family=Single+Day&display=swap"
          rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="css/chat.css">
    <link rel="stylesheet" href="css/style.css">
    <script>
        // jsp 관련 전역 변수로 선언 (window 객체에 추가)
        window.objectStorageUrl = "${objectStorageUrl}";
        window.imageOptimizerFrontUrl = "${imageOptimizerFrontUrl}";
        window.imageOptimizerBackUrl = "${imageOptimizerBackUrl}";
        window.isLogin = "${sessionScope.isLogin}";
        window.nickname = "${sessionScope.nickname}";  // 여기에서 nickname을 먼저 정의
        window.profileImage = "${sessionScope.profileImage}";

        // 로그인 여부 확인
        if (!isLogin) location.href = '/login';
    </script>
    <script src="js/chat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js"></script>
    <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js"></script>
    <script src="js/fcmSetup.js"></script>
    <script>
        (function(d) {
            var config = {
                    kitId: 'esg6tsh',
                    scriptTimeout: 3000,
                    async: true
                },
                h=d.documentElement,t=setTimeout(function(){h.className=h.className.replace(/\bwf-loading\b/g,"")+" wf-inactive";},config.scriptTimeout),tk=d.createElement("script"),f=false,s=d.getElementsByTagName("script")[0],a;h.className+=" wf-loading";tk.src='https://use.typekit.net/'+config.kitId+'.js';tk.async=true;tk.onload=tk.onreadystatechange=function(){a=this.readyState;if(f||a&&a!="complete"&&a!="loaded")return;f=true;clearTimeout(t);try{Typekit.load(config)}catch(e){}};s.parentNode.insertBefore(tk,s)
        })(document);
    </script>
</head>
<body>
<div id="chatContainer" class="frame">
    <div class="background">
        <div id="header">
            <%--        <span id="chatTitle">BitSync502</span>--%>
            <a href="#" data-bs-toggle="popover" data-bs-placement="bottom"
               id="popoverBtn">
                <img src="${sessionScope.profileImage}" id="topImage">&nbsp;${sessionScope.nickname}님, 안녕하세요!
            </a>
            &nbsp;&nbsp;
            <div id="subscribe">
                <i class="bi bi-bell-slash" id="subscribeBtn"></i>
                <i class="bi bi-bell-fill" id="unsubscribeBtn"></i>
            </div>
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
                            tilte="이미지 미리보기">+
                    </button>
                    <input type="file" name="chatImage" id="imageInput" accept="image/*" hidden/>
                    <input type="text" name="message" id="messageInput" placeholder="메세지를 입력하세요"/>
                    <button type="submit" id="sendBtn">전송</button>
                </form>
            </div>
        </div>
    </div>

    <!-- 모달 -->
    <div id="chatModal" class="chatModal">
        <div class="modalContent">
            <img id="modalImage" src="" style="max-width: 100%;">
        </div>
    </div>

    <!-- bs5 toast : 채팅 입력 알림 -->
    <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1100">
        <div id="noChatInputToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true"
             data-bs-delay="1500">
            <div class="toast-body">
                채팅을 입력해주세요.
            </div>
        </div>
    </div>

    <!-- bs5 toast : 채팅 입력 알림 -->
    <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 1100">
        <div id="subscribeToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true"
             data-bs-delay="3000">
            <div class="toast-body" id="subscribeToastBody">
            </div>
        </div>
    </div>
</div>
</body>
</html>