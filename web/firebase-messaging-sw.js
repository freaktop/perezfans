importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyD7FWFvyb7VyvA4vf1kDFU7avHvuysz19U',
  authDomain: 'perezfans.firebaseapp.com',
  projectId: 'perezfans',
  storageBucket: 'perezfans.firebasestorage.app',
  messagingSenderId: '547851710384',
  appId: '1:547851710384:web:df4b5416d0698762acb075',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  const notificationTitle = payload.notification?.title || 'PerezFans';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: payload.notification?.icon || '/favicon.png',
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});
