create table chat
(
    idx          int auto_increment                 primary key, # 댓글 번호
    nickname     varchar(30)                        not null,    # 닉네임
    message      varchar(2000)                      not null,    # 메세지
    profileImage varchar(200)                       not null,    # 프로필 사진
    createdAt    datetime default CURRENT_TIMESTAMP null,        # 작성 일시
    chatImage    varchar(255)                       null         # 채팅 이미지
);

create table chatFcmTokens
(
    token varchar(255) not null primary key                      # Firebase FCM Token
);
