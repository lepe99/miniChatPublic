# BitSync: 실시간 채팅 웹 애플리케이션

<div align="center">
    
**Bit [비트캠프, 디지털 정보에서의 작은 데이터 단위] + Sync [동기화]**

[![BitSync 502](https://img.shields.io/badge/BitSync-502-blue?style=for-the-badge)](https://502chat.kro.kr/)

</div>

## 추가 자료
[프로젝트 문서 보기](https://drive.google.com/file/d/1koVwf8wJQTUOqyvNhyVFC1d-oxWLYvj4/view?usp=sharing)
[프로젝트 ppt 보기](https://drive.google.com/file/d/YOUR_FILE_ID/view)

## 📝 프로젝트 개요

비트캠프 네이버클라우드 17기 과정 중에 과제로 수행한 2인 협업 프로젝트입니다. 12주의 교육과정 이후 주어진 두 번째 프로젝트 과제이며, 첫 번째 협업 과제입니다.

- **개발 기간**: 5일 (2025.03.05 ~ 2025.03.09)
- **목표**: Git 협업 연습 및 교육 기간에 배운 기술 복습, 추가적인 기술적 도전
- **특징**: 
  - 실제 사용할 수 있는 사용자 중심 웹 프로젝트 구현
  - WebSocket 프로토콜을 활용한 실시간 채팅 
  - 웹 푸시 알림 기능 구현
  - 사용자 경험을 위한 직관적인 인터페이스 설계

## 🛠️ 기술 스택

<div align="center">

<img src="https://firebasestorage.googleapis.com/v0/b/stackticon-81399.appspot.com/o/images%2F1741810530141?alt=media&token=9d3fe613-657b-4597-8ff3-d04839778468" alt="스택">

</div>

### 주요 기술
- **서버, 웹 페이지 구현**: Java, Spring Boot, JSP & JSTL, JavaScript, jQuery, HTML, CSS
- **데이터베이스**: MySQL, MyBatis
- **배포**: Docker, Tomcat, Jenkins, NCP services (server, object storage, MySQL server)
- **API**: Firebase Cloud Messaging, Kakao Login
- **인증**: Let's Encrypt SSL

## 🔍 시스템 구성도

<img src="/introduce/files/project.png" alt="시스템 구성도">

- **빌드 및 배포**:
  - Maven을 사용하여 WAR로 빌드
  - 외장 Tomcat 서버를 이용한 배포
  - Jenkins를 활용한 CI/CD 파이프라인 구축
  - Docker 컨테이너로 Jenkins와 Tomcat 서버 분리
  - 포트 매핑: HTTP(80) → 8080, HTTPS(443) → 8443
  - HTTP 접근 시 HTTPS로 자동 리다이렉트

## ✨ 주요 기능

### 로그인 시스템
- 카카오 로그인 API를 활용한 간편 로그인
- 사용자 닉네임과 프로필 사진을 세션에 저장
- 로그아웃 시 세션 만료 및 로그인 페이지 리다이렉트
<img src="/introduce/files/login.png" alt="시퀀스-로그인">

### 채팅 시스템
- WebSocket 프로토콜을 활용한 실시간 채팅
- 메시지 타입 구분 (입장/퇴장/메시지/사용자 리스트)
- 이미지 첨부 및 전송 기능
- 사용자 접속 상태 실시간 갱신
- Heartbeat 메커니즘으로 안정적인 연결 유지
- 10분 이상 유휴 상태 시 웹소켓 & http 세션 자동 종료
<img src="/introduce/files/websocket1.png" alt="시퀀스-채팅1">
<img src="/introduce/files/websocket2.png" alt="시퀀스-채팅2">

### 데이터 관리
- 최근 100개 채팅 내역 DB 저장 및 로드
- 오래된 채팅 자동 삭제 (DB 및 Object Storage에서)
- 비동기 처리로 채팅 반응성 유지
<img src="/introduce/files/db.png" alt="시퀀스-데이터베이스">

### 푸시 알림
- Firebase Cloud Messaging 기반 웹 푸시 알림
- DB로 사용자의 FCM 토큰 관리, 토큰 갱신 시 정합성 유지
- 알림 설정/해제 기능
- 브라우저 로컬 스토리지를 활용한 알림 설정 상태 관리
<img src="/introduce/files/fcm.png" alt="시퀀스-알림">

### 보안 기능
- HTTPS 프로토콜 적용
- Let's Encrypt SSL 인증서 사용
- 사용자 채팅에 HTML 이스케이프 처리로 XSS 방지

## 🖌️ UI/UX 고려사항

- **CSS Flexbox 레이아웃**: 다양한 화면 크기에 유연하게 대응
- **세션 관리**: 만료된 세션 처리 및 재로그인 안내
- **직관적인 사용자 인터페이스**:
  - 사진 업로드 미리보기 (Popover 활용)
  - 프로필 클릭 시 로그아웃 버튼 표시 (Popover 활용)
  - 이미지 로드 최적화 (NCP Image Optimizer 활용)
  - 원본 이미지 모달 뷰
- **사용성 개선**:
  - 빈 메시지 전송 방지 및 알림 (Toast 활용)
  - Toast, Modal, Popover 애니메이션 적용
  - 중복 사용자 표시 방지
  - 대용량 이미지 처리 및 중복 전송 방지
  - 파일 크기 제한 (10MB) 및 예외 처리
  - 알림 설정/해제 버튼 UX 개선

## 🚀 구현 과정

### 1단계: 기본 기능 구현 (3일)
- 카카오 로그인 기능 구현
- WebSocket 프로토콜 구현
- 페이지 구현, CSS Flexbox 레이아웃 설정
- 실시간 채팅 기능 구현
- 1차 배포

### 2단계: 사용자 경험 개선 (2일)
- 사용자 경험 개선점 식별 및 수정
- HTTPS 프로토콜 적용
- 웹 푸시 알림 구현
- PWA 특성 적용

## 🔧 도전 과제 및 해결 방법

### WebSocket 구현 도전
- 스레드 경합으로 인한 문제 발생
- LinkedBlockingQueue, ConcurrentHashMap, CopyOnWriteArrayList 활용하여 동시성 제어
- Heartbeat 메커니즘 구현으로 연결 안정성 확보

### HTTPS 프로토콜 적용
- Let's Encrypt SSL 인증서 발급
- Docker Tomcat 설정 최적화
- HTTP → HTTPS 리다이렉트 설정

### 웹 푸시 알림 구현
- Firebase Cloud Messaging 서비스 활용
- 서비스 워커 구현
- 토큰 관리 및 갱신 메커니즘 구축

## 🔜 향후 개선점

### 공통
- 특정 사용자 태그 및 알림 기능 구현

### 프론트엔드
- 다양한 파일 형식 지원 및 영상 미리보기 기능
- 모바일 환경을 위한 반응형 웹 디자인 개선

### 백엔드
- 단위 테스트 및 부하 테스트 구현
- CI/CD 파이프라인에 자동 테스트 통합
- 체계적인 로깅 시스템 구축

## 👥 참여자 및 역할

### 이원재 (백엔드)
- 프로젝트 기획
- 채팅 및 웹 푸시 알림 기능 구현
- 사용자 세션 관리
- 프로젝트 배포 및 HTTPS 프로토콜 설정
- DB CRUD 작업

### 오하늬 (프론트엔드)
- 프로젝트 기획 및 브랜딩
- 로그인 기능 및 페이지 구현/디자인
- UI/UX 개선
- DB 세팅

## 💭 프로젝트 소감

>  서로 노력한 만큼 좋은 결과물이 나와 정말 뜻깊고 보람찬 프로젝트였습니다. 짧은 시간 내에 새로운 기술들을 배워 구현하는 과정이 순탄치 않았지만, 고생한 만큼 성장하는 계기가 되었습니다. 이 경험을 통해 앞으로도 낯선 기술을 도입할 필요성이 있을 때 두려움 없이 도전할 수 있을 것 같습니다.
단지 기술 연습용 토이 프로젝트가 아닌, 실제 사용자를 유치할 수 있는 프로젝트를 만들자는 목표도 큰 도움이 되었습니다. 기술적 문제뿐만 아니라 사용자 관점에서 불편할 수 있는 상황을 가정하고 찾아내어 하나하나 해결해가며 시야를 넓힐 수 있었습니다. <br>
 Git을 본격적으로 사용하는 것은 처음이고 협업도 처음이라 막연한 두려움을 가지고 프로젝트를 시작했지만, 서로 원활한 소통과 의견 조율을 통해 생각보다 훨씬 순조롭게 마무리할 수 있었습니다. Git은 완벽히 숙달하지는 못했지만, 개발 브랜치에 서로의 작업물을 병합하며 발생하는 여러 충돌을 해결하는 과정에서 Git에 대한 이해도가 크게 향상되었습니다.
소규모 협업이었고 대부분의 시간을 오프라인으로 같은 공간에서 서로 코드 리뷰를 하며 작업했기에 Pull Request를 사용해보지 못한 한계점이 있습니다. 다음 협업에서는 이번 경험을 바탕으로 Pull Request를 활용하여 더욱 체계적인 협업을 할 수 있도록 노력하겠습니다.
감사합니다!" - 이원재
