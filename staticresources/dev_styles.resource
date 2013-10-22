/* ========================================
    Browser Reset
=========================================*/

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
    margin: 0;
    padding: 0;
    border: 0;
    font-size: 100%;
    font: inherit;
    vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
    display: block;
}
body {
    line-height: 1;
	margin: 0;
}
ol, ul {
    list-style: none;
}
blockquote, q {
    quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
    content: '';
    content: none;
}
table {
    border-collapse: collapse;
    border-spacing: 0;
}
 
 
/*=========================================
    Main Styles
=========================================*/

body {
	font-family: Arial,Helvetica,sans-serif;
	font-size: 11px;
	line-height: 16px;
	color: #222;
	margin:0px;
}
a {
	color:#1797C0;
}
a:hover, a:active {
	outline: 0;
}



/*=========================================
    Login Specific
=========================================*/

h1.title{
	font-weight:bold;
	margin-bottom:10px;
}

h1.input{
	margin-bottom:10px;
}

.error {
	background-color: #fff;
	border: 2px solid #CC0000;
}
label.error {
	color: #D74C3B;
	border: none;
	background-color:transparent;
}
label.remember {
	display: inline-block;
	vertical-align: top;
}
.btnLogin {
	-moz-border-bottom-colors: none;
	-moz-border-image: none;
	-moz-border-left-colors: none;
	-moz-border-right-colors: none;
	-moz-border-top-colors: none;
	background: #4088BF;
	border-color: #1A527D #1A527D #0F3049;
	border-radius: 2px 2px 2px 2px;
	border-style: solid;
	border-width: 1px;
	color: #FFFFFF;
	font-weight: bold;
	margin: 3px 7px 0;
	padding: 3px 7px;
	text-shadow: 0 -1px #174B73;
	cursor: pointer;
	float:right;
}
.btnLogin:hover,
.btnLogin:focus,
.btnLogin:active {
	border: 1px solid #0F3049;
	opacity: 0.95;
}
.btnLogin:active {
	box-shadow: 0 0 0.5em #174B73 inset;
}
.btnLogin:active {
	text-shadow:rgba(0,0,0,0.3) 0 -1px 0px; 
}


/*=========================================
    CTI Specific
=========================================*/

h1.agentName{
	font-weight:bold;
	width:125px;
	float:left;
}

a.logout{
	 float:right;
}

input, select, textarea {
	font-family: Arial,Helvetica,sans-serif;
	font-size: 11px;
	padding:2px;
	margin:0;
}
.container {
	width:100%;
	display:none;
	padding:10px 9px;
	border-radius:5px !important;
	-webkit-border-radius: 5px;
	-moz-border-radius:5px;
	box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -moz-box-sizing: border-box;
}

.fwidth {
	width:100%;
}
.swidth {
	width:100%;
	color:#666;
	-moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    box-sizing: border-box
}

.info_row{
	border-bottom:1px solid #b4d6e1;
}
.info_label {
	font-weight:bold;
	width:80px;
	padding: 3px 0px;
}
.head {
	text-decoration:none;
	display:block;
	padding:3px 9px;
	background:#1797C0;
	color:#ffffff;
	font-weight:bold;
	border-radius:3px !important;
	-webkit-border-radius: 3px;
	-moz-border-radius:3px;	
}
.content {
	display:none;
	padding:3px;
	box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -moz-box-sizing: border-box;
}

ul#callInfoList {
	margin-top:5px;
}

ul#callInfoList li {
	position:relative;
	overflow:hidden;
	margin-top:5px;
}

 .caller-info a {
	color:#222;
	text-decoration:underline;
}
.caller-info a:hover {
	color:#015BA7;
}

.branding {
	text-align:right;
	margin-top:10px;
	margin-bottom:20px;
}

.float_clear {
	clear:both;
	margin-bottom:5px;
}

.log_success{
	font-weight: bold;
	background-image: url(../images/tick.png);
}

.log_error{
	font-weight: bold;
	background-image: url(../images/exclamation-red.png);
}

.comments_field{
	border:1px solid;
	padding:0px;
	resize:none;
	margin-bottom: 10px;
}


/*=========================================
    Dialpad Buttons
=========================================*/

a.callButton{
	display:block;
	width:169px;
	height:20px;
	text-indent:-9999px;
	background-image: url(../images/call-button.png);
}

a.callButton:hover {
	background-position: 0px -23px;
}

table.dialpad {
	margin:0px;
}
table.dialpad td {
	width:56px;
	padding:1px;
}
table.dialpad a {
	display:block;
	width:52px;
	height:20px;
	text-indent:-9999px;
	background-image: url(../images/buttons.png);
}
a.b1 { background-position: 0px 0px; }
a.b2 { background-position: 0px -30px; }
a.b3 { background-position: 0px -60px; }
a.b4 { background-position: 0px -90px; }
a.b5 { background-position: 0px -120px; }
a.b6 { background-position: 0px -150px; }
a.b7 { background-position: 0px -180px; }
a.b8 { background-position: 0px -210px; }
a.b9 { background-position: 0px -240px; }
a.bstar { background-position: 0px -270px; }
a.b0 { background-position: 0px -300px; }
a.bpound { background-position: 0px -330px; }

a.b1:hover { background-position: -62px 0px; }
a.b2:hover { background-position: -62px -30px; }
a.b3:hover { background-position: -62px -60px; }
a.b4:hover { background-position: -62px -90px; }
a.b5:hover { background-position: -62px -120px; }
a.b6:hover { background-position: -62px -150px; }
a.b7:hover { background-position: -62px -180px; }
a.b8:hover { background-position: -62px -210px; }
a.b9:hover { background-position: -62px -240px; }
a.bstar:hover { background-position: -62px -270px; }
a.b0:hover { background-position: -62px -300px; }
a.bpound:hover { background-position: -62px -330px; }

table.dialcall {
	margin:0px;
}

/*table.dialcall a {
	display:block;
	width:169px;
	height:20px;
	text-indent:-9999px;
	background-image: url(../images/call-button.png);
}
table.dialcall a:hover {
	background-position: 0px -23px;
}

table.endcall {
	margin:0 0 0 4px;
}
table.endcall a {
	display:block;
	width:169px;
	height:20px;
	text-indent:-9999px;
	background-image: url(../images/end-call-button.png);
}
table.endcall a:hover {
	background-position: 0px -23px;
}*/

/*=========================================
    Extension Selector
=========================================*/


.ui-dropdownchecklist {
	font-size: 11px;
	color: #222;
	border: solid 1px #abadb3;
	background-color: #fff;
}
.ui-dropdownchecklist-selector {
	height: 11px;
	padding:1px;
}
.ui-dropdownchecklist-dropcontainer {
	background-color: #fff;
}
.ui-dropdownchecklist-dropcontainer-wrapper {
	border-width:0 1px 1px 1px;
}
.ui-dropdownchecklist-item {
	text-align:left;
}
.ui-dropdownchecklist-item  {
	padding:2px 4px;
}
.ui-dropdownchecklist-item input {
	margin-right: 5px;
	vertical-align: bottom;
	position: relative;
	top: -1px;
}
.ui-dropdownchecklist-group {
	font-weight: bold;
	font-style: italic;
}
.ui-dropdownchecklist-indent {
	padding-left: 0;
}
.ui-dropdownchecklist-selector-wrapper {
	vertical-align: middle;
}
.ui-dropdownchecklist-text {
	text-align:left;
	margin-top:-2px;
}