// Firebase 설정
const firebaseConfig = {
    apiKey: "AIzaSyBuu_9t5reaIbX5Vw7owyJCkSd9KYZqJA0",
    authDomain: "minichat-d6f16.firebaseapp.com",
    projectId: "minichat-d6f16",
    storageBucket: "minichat-d6f16.firebasestorage.app",
    messagingSenderId: "129867890034",
    appId: "1:129867890034:web:0a06e46701c4bbc662b1eb"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

// Service Worker 등록
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/js/fcmServiceWorker.js')  // serviceWorker.js 경로
        .then(function (registration) {
            console.log('Service Worker registered with scope:', registration.scope);
            messaging.useServiceWorker(registration); // Firebase Messaging에 Service Worker 사용

            // 구독 버튼 클릭 핸들러 (이벤트 리스너 사용)
            const subscribeBtn = document.getElementById('subscribeBtn');
            const unsubscribeBtn = document.getElementById('unsubscribeBtn');
            if (subscribeBtn) {
                subscribeBtn.addEventListener('click', subscribe);
            }
            if (unsubscribeBtn) {
                unsubscribeBtn.addEventListener('click', unsubscribe);
            }

            //구독 상태에 따라 버튼 변경
            updateButtonState();


        }).catch(function (err) {
        console.log('Service Worker registration failed:', err);
    });
}

// 구독 버튼 클릭 핸들러
function subscribe() {
    $("#subscribe").addClass('disableClick') // 중복 클릭 방지
    Notification.requestPermission().then((permission) => {
        if (permission === 'granted') {
            console.log('Notification permission granted.');
            messaging.getToken({vapidKey: 'BPCr25Fjece9BkFDk_-iOdZe8a6F4WhsizzTgEBAtLJdsZFE-rDgjJzCD7RHU8U8e5T_NL0W1oCgaYESYoE6Ce8'})
                .then((currentToken) => {
                    if (currentToken) {
                        // 버튼 변경
                        $('#subscribeBtn').hide();
                        $('#unsubscribeBtn').show();

                        console.log('FCM Token:', currentToken);
                        sendTokenToServer(currentToken); // 서버로 토큰 전송
                        showSubscribeToast("채팅 알림 설정이 완료되었습니다."); // 토스트 메시지 표시
                        $("#subscribe").removeClass('disableClick') // 중복 클릭 방지 해제

                    } else {
                        console.log('No registration token available.');
                        setTokenSentToServer(false);
                        $("#subscribe").removeClass('disableClick') // 중복 클릭 방지 해제
                    }
                }).catch((err) => {
                console.log('An error occurred while retrieving token. ', err);
                setTokenSentToServer(false);
                $("#subscribe").removeClass('disableClick') // 중복 클릭 방지 해제
            });
        } else {
            console.log('Unable to get permission to notify.');
            alert('알림 권한이 거부되었습니다.');
            $("#subscribe").removeClass('disableClick') // 중복 클릭 방지 해제
        }
    });
}

// 구독 취소 함수
function unsubscribe() {
    $("#subscribe").addClass('disableClick'); // 중복 클릭 방지
    messaging.getToken({vapidKey: 'BPCr25Fjece9BkFDk_-iOdZe8a6F4WhsizzTgEBAtLJdsZFE-rDgjJzCD7RHU8U8e5T_NL0W1oCgaYESYoE6Ce8'}) // VAPID
        .then((currentToken) => {
            if (currentToken) {
                messaging.deleteToken(currentToken) // 현재 토큰 삭제
                    .then(() => {

                        // 버튼 변경
                        $('#subscribeBtn').show();
                        $('#unsubscribeBtn').hide();

                        deleteToken(currentToken); // 서버에서도 토큰 삭제
                        showSubscribeToast("채팅 알림 설정이 해제되었습니다."); // 토스트 메시지 표시
                        $("#subscribe").removeClass('disableClick') // 중복 클릭 방지 해제

                    })
                    .catch((err) => {
                        console.log('Unable to delete token. ', err);
                        $("#subscribe").removeClass('disableClick') // 중복 클릭 방지 해제
                    });
            } else {
                console.log("No token to delete");
                setTokenSentToServer(false);
                $("#subscribe").removeClass('disableClick') // 중복 클릭 방지 해제
            }
        })
        .catch((err) => {
            console.log('An error occurred while retrieving token. ', err);
            $("#subscribe").removeClass('disableClick') // 중복 클릭 방지 해제
        });
}


// 토큰 갱신 리스너 (필요한 경우)
messaging.onTokenRefresh(() => {
    messaging.getToken().then((refreshedToken) => {
        console.log('Token refreshed.');
        let currentToken = window.localStorage.getItem('token');
        if (currentToken) deleteToken(currentToken); // 서버에 저장된 토큰 삭제
        sendTokenToServer(refreshedToken);
    }).catch((err) => {
        console.log('Unable to retrieve refreshed token ', err);
    });
});

// 서버로 토큰 전송
function sendTokenToServer(token) {
    if (!isTokenSentToServer()) {
        console.log('Sending token to server...');
        saveToken(token); // 서버에 토큰 저장 요청
    } else {
        console.log('Token already sent to server so won\'t send it again ' +
            'unless it changes');
    }
}


// LocalStorage에 토큰 전송 여부, 토큰 저장
function setTokenSentToServer(sent, token = null) {
    window.localStorage.setItem('sentToServer', sent ? '1' : '0');
    if (sent) {
        window.localStorage.setItem('token', token);
    }
}

// LocalStorage에서 토큰 전송 여부 가져오기
function isTokenSentToServer() {
    return window.localStorage.getItem('sentToServer') === '1';
}

// 서버에 토큰 저장 요청
function saveToken(token) {
    $.ajax({
        url: '/fcm/saveToken',
        type: 'POST',
        data: {token: token},
        success: function (response) {
            console.log('Token sent to server successfully:', response);
            setTokenSentToServer(true, token);
        },
        error: function (error) {
            console.error('Error sending token to server:', error);
            setTokenSentToServer(false);
        }
    });
}

// 서버에 토큰 삭제 요청
function deleteToken(token) {
    $.ajax({
        url: '/fcm/deleteToken',
        type: 'POST',
        data: {token: token},
        success: function (response) {
            console.log('Token deleted from server successfully:', response);
            setTokenSentToServer(false);
        },
        error: function (error) {
            console.error('Error deleting token from server:', error);
        }
    });
}

// 버튼 상태 업데이트 함수
function updateButtonState() {
    const subscribeBtn = document.getElementById('subscribeBtn');
    const unsubscribeBtn = document.getElementById('unsubscribeBtn');
    // LocalStorage에서 구독 상태 확인
    const isSubscribed = isTokenSentToServer();

    if (isSubscribed) {
        if (subscribeBtn) subscribeBtn.style.display = 'none';
        if (unsubscribeBtn) unsubscribeBtn.style.display = 'inline-block';
    } else {
        if (subscribeBtn) subscribeBtn.style.display = 'inline-block';
        if (unsubscribeBtn) unsubscribeBtn.style.display = 'none';
    }
}

// 구독 알림 토스트
function showSubscribeToast(text) {

    // Toast 보여주기
    var toastEl = document.getElementById('subscribeToast');
    $("#subscribeToastBody").text(text);
    var toast = new bootstrap.Toast(toastEl);
    toast.show();
}