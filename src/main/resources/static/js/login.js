Kakao.init(`${kakaoJavascriptKey}`); // Kakao Developers에서 발급받은 JavaScript 키

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