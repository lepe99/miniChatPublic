importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js');

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


// 백그라운드 메시지 핸들러
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.data.title;
    const notificationOptions = {
        body: payload.data.body,
        icon: payload.data.icon,
        data: {
            url: payload.data.url
        }
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});

// 알림 클릭 이벤트 처리
self.addEventListener('notificationclick', (event) => {
    console.log('[firebase-messaging-sw.js] Notification clicked:', event.notification);
    event.notification.close();

    // 알림 클릭 시 수행할 작업 (예: 특정 URL 열기)
    event.waitUntil(
        clients.openWindow(event.notification.data.url)
    );
});