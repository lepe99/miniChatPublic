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
    <style>
        .sphoto {
            width: 30px;
            height: 30px;
        }

        .frame {
            display: flex;
            flex-direction: column; /* 상단(top)과 나머지 부분을 세로 정렬 */
            height: 100vh;
            padding: 20px;
        }

        /* 상단 박스 */
        .top {
            display: flex;
            height: 60px;
            margin-bottom: 20px;
            background-color: mistyrose;
            justify-content: flex-end; /* 내부 요소를 오른쪽 정렬 */
            align-items: center; /* 수직 가운데 정렬 */
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
            background-color: #3e71a5;
            color: white;
            align-items: center;
            padding: 20px;
            display: flex;
            flex-direction: column; /* 내부 요소를 세로 정렬 */
            margin-right: 20px;
        }

        /* 오른쪽 채팅 영역 */
        .right {
            flex: 1; /* 남은 공간을 모두 차지 */
            background-color: yellow;
            display: flex;
            flex-direction: column;
        }
    </style>
    <script>
        $(document).ready(function () {
            let isLogin = "${sessionScope.isLogin}";//로그인 됐으면 true
            if (!isLogin) {
                location.href = '/login';
            }
        });
    </script>
</head>
<body>
<div class="frame">
    <div class="top">
        <span>채팅창</span>
        <img src="${sessionScope.profileImage}" class="sphoto">${sessionScope.nickname}
        <button class="logout" onclick="location.href='logout'">로그아웃</button>
    </div>
<div class="chat">
    <div class="left">
        ff
    </div>

    <div class="right">
        ff
    </div>
</div>
</div>
</body>
</html>