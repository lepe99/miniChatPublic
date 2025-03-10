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
    <link rel="stylesheet" href="css/login.css">
    <link rel="stylesheet" href="css/style.css">
    <script src="https://developers.kakao.com/sdk/js/kakao.js"></script>
    <script>
        window.kakaoJavascriptKey = "${kakaoJavascriptKey}";
    </script>
    <script src="js/login.js"></script>
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
<style>

</style>
<body>

<div class="frame">
    <div class="background">
        <div class="loginwindow">
            <img src="../img/moon.png" class="sunimg"><br>
            <span id="welcome">Welcome!</span><br>
            <span id="bitsync">we are "BitSync 501"</span><br><br>
            <span id="logintext">please login</span><br>
            <img src="../img/kakao_login_medium_narrow.png" class="loginbtn" onclick="loginWithKakao()">
<%--            <button class="loginbtn" onclick="loginWithKakao()"><img src="">카카오톡 로그인</button>--%>
        </div>
    </div>
</div>
</body>
</html>