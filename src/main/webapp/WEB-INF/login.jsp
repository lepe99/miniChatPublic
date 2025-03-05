<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
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
        .frame{
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #ffffff;
        }
        .background{
            display: flex;
            align-items: center;
            justify-content: center;
            width: 95%;
            height: 90%;
            min-height: 400px;
            max-height: 1080px;
            min-width: 300px;
            max-width: 1800px;
            padding: 20px;
            background-color: #dcdcdc;
            text-align: center;
            border-radius: 20px;
        }
        .loginwindow{
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 350px;
            height: 300px;
            background-color: lightblue;
            border-radius: 20px;
        }

        .loginbtn:hover{
            cursor: pointer;
        }
        .sunimg{
            width: 150px;
        }
    </style>
</head>
<body>

<div class="frame">
    <div class="background">
        <div class="loginwindow">
            <img src="../img/moon.png" class="sunimg"><br>
            <img src="../img/kakao_login_medium_narrow.png" class="loginbtn" onclick="loginWithKakao()">
<%--            <button class="loginbtn" onclick="loginWithKakao()"><img src="">카카오톡 로그인</button>--%>
        </div>
    </div>
</div>

<script src="https://developers.kakao.com/sdk/js/kakao.js"></script>
<script>
    Kakao.init('1449c4fc9eb007b995d91b343053da4a'); // Kakao Developers에서 발급받은 JavaScript 키

    function loginWithKakao() {
        Kakao.Auth.login({
            success: function(authObj) {
                // 로그인 성공 시 callback
                console.log(authObj); // Access Token, Refresh Token 등
                // 서버로 Access Token 전송 (AJAX)
                sendAccessToken(authObj.access_token);
            },
            fail: function(err) {
                // 로그인 실패 시 callback
                console.error(err);
                alert('카카오 로그인에 실패했습니다.');
            }
        });
    }

    function sendAccessToken(accessToken) {
        $.ajax({
            type: 'POST',
            url: '/login/kakao', // 서버의 Access Token 처리 엔드포인트
            data: { accessToken: accessToken },
            success: function(response) {
                // 서버에서 사용자 정보 처리 후 응답 (예: 리다이렉트)
                if (response.success) {
                    window.location.href = "/"; // 메인 페이지 또는 원하는 페이지로 리다이렉트
                } else {
                    alert("로그인 처리 실패: " + response.message);
                }

            },
            error: function(xhr, status, error) {
                console.error(error);
                alert('서버와 통신 중 오류가 발생했습니다.');
            }
        });
    }

</script>
</body>
</html>