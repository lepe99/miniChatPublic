// chat.jsp 페이지로 옮길 스크립트




// 메세지 출력
function displayMessage(message) {
    console.log("메세지 출력");
    let timestamp = new Date().toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'});

    let messageHtml = "";
    if (message.nickname === "${sessionScope.nickname}") {
        //내 메세지(오른쪽 하단 정렬, 프로필 닉네임 표시안하고 타임스탬프 왼쪽)
        messageHtml = `
                    <div class="mymessage">
                        <span class="timestamp">${timestamp}</span>
                        <div class="messagecontent">${message.content}</div>
                    </div>
                    `;
    } else {
        //상대방메세지 (왼쪽 하단 정렬, 프로필+닉네임 표시 , 타임스탬프 오른쪽)
        messageHtml = `
                    <div class="othermessage">
                        <div class="prifilecontainer">
                            <img src="${message.profileImage}" class="profileImg">
                            <span class="nickname">${message.nickname}</span>
                        </div>
                        <div class="messagecontainer">
                            <div class="messagecontent">${message.content}</div>
                            <span class="timestamp">${timestamp}</span>
                        </div>
                    </div>
                    `;
    }

    // console.log("추가할 HTML:", messageHtml); // ✅ HTML 코드 확인
    chatBox.append(messageHtml);
    // console.log("현재 chatBox 내용:", chatBox.html()); // ✅ chatBox에 추가되었는지 확인
    chatBox.scrollTop(chatBox.prop("scrollHeight")); // 스크롤 아래로 이동
}