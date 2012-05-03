{literal}
<style>
@media all
{
  .page-break  { display:none; }
}

@media print
{
  .page-break  { display:block; page-break-before:always; }
}

#badge img,#vbadge img{visibility:hidden;}
#badge .active,#vbadge .active {display:block;position:absolute;left:0;top:0;width:100%;height:100%;z-index:1;visibility:visible}
#qrcode {position:absolute;top:1mm;right:1mm;z-index:10}
#editor {position:relative;z-index:1000;}
#restmsg.msgnok, span.msgnok {
    display:block;
    background:yellow;
    background-color:yellow;
    border:1px solid red;
    color:red;
    font-size:12px;
    margin:0 0 8px;
    padding:4px;
}
#toolview {position:absolute;left:300px;padding:10px 10px 10px 20px;background:white}

#display_name {display:block;font-size:20px;top:50mm;text-align:left;z-index:10;
left:10mm;
position:absolute;
}
#second{font-size:15px;top:60mm;
left:10mm;
text-align:left;z-index:10;position:absolute;}
#badge_id {position:absolute;z-index:10;left:1mm;top:0mm;}

.separator, #aabadge_country {display:none;}

#editor input {display:block;}
#editor {position:absolute;top:100px;left:0px}
.live_event {position:relative;}
#crm-container .ac_input {width:10em;z-index:20}

.ui-autocomplete {background:white;z-index:10000;}

#participant_search {display:inline;}
#crm-container .crm-actions-ribbon li {padding:2px 10px;}

#wrapper {height:100%;width:100%;border:1px solid pink;}

@media screen {
  #badge {border:1px solid;width:97mm;height:86mm;position:absolute;top:300px;left:555px;}
  #vbadge {display:none;visibility:hidden;position:absolute;top:300px;left:855px;height:97mm;width:86mm;}
#badge img,#vbadge img{visibility:hidden;width:100px;height:100px;}
#b1,#b2 {visibility:hidden;}
#message  {display:none;}
}

@media print {
  * {font-family:Helvetica, Arial, sans serif}
  .container { visibility:hidden;text-shadow:none;}
  .crm-button {border:none!important;}
  body {height:297mm;width:210mm;position:absolute;top:0; left:0;}
  h1 {text-shadow:none;}
  #logo {display:none;}
  #wrapper {position:inherit;}
  input {display:none;visibility:hidden;}
  #message {position:absolute;top:30px; left:10px;font-size:18px;display:block;}
/*  .fbadge,.vbadge {width:97mm!important;height:86mm!important;position:fixed;bottom:0;left:0;visibility:visible!important;display:block;}*/
  .fbadge,.vbadge {width:50%!important;height:86mm!important;position:fixed;bottom:0;left:0;visibility:visible!important;display:block;}
  .fbadge img,.vbadge img {width:50%;height:86mm} 
  .vbadge {left:auto;right:0;} 

  

  .role_3 * {font-weight:bold;} /* dear firefox, why are you ignoring color:#fff but that #f00 is fine? */

  #all {position:fixed;display:block;visibility:visible;border:black 1px solid;top:0;right:0;bottom:0;left:0}
  #half {position:fixed;display:block;visibility:visible;border:black 1px solid;top:0;left:0;bottom:0;width:50%;}

#b1,#b2 {position:fixed;top:50mm;left:0mm;width:97mm;height:86mm;border:1px solid red;}
#b1 img,#b2 img {width:97mm;height:86mm;display:none;position:absolute;}
#b2 {position:fixed;top:40mm;left:50%; border:1px solid green;}


.fbadge *, .vbadge * {text-transform:uppercase}
.role_3 * {color:#000}

.status_1 {}
.status_2 {font-weight:bold;}
</style>
{/literal}
<script>
var margin = [20,8,20,8];
var participants={$participants_json};
var event_id={$event->id};
var options = {ldelim} ajaxURL:"{crmURL p='civicrm/ajax/rest' h=0}"
       ,closetxt:'<div class="ui-icon ui-icon-close" style="float:left"></div>'{rdelim};

var tttp_root = '{$tttp_root}';
{literal}
var urlParams = {};
(function () {
  var e,
      a = /\+/g,  // Regex for replacing addition symbol with a space
      r = /([^&=]+)=?([^&]*)/g,
      d = function (s) { return decodeURIComponent(s.replace(a, " ")); },
      q = window.location.search.substring(1);

  while (e = r.exec(q))
     urlParams[d(e[1])] = d(e[2]);
})();

if (urlParams['margin']) {
  var tmp = urlParams['margin'].split(",",4);
  for (i=0;i<=3;i++) {
    if (isNaN(tmp[i])) {
      alert ("invalid margin, should be '&margin=top,right,bottom,left' eg. margin=20,9,20,9");
      break;
    }
    margin [i]= tmp [i];
  }
}

//jQuery(function($){
cf(function($){

  var fields=['first_name','last_name','country', 'country_id','organization_name','employer_id','id','contact_id','email','role_id','email_id','address_id'];

  var setParticipant =function (data) {
    setBackground(data['role_id']);
    document.title = data['last_name']+ " "+ data['first_name'];
    window.location.hash = data['id'];
    qrcode ("#qrcode",data);
    $.each(fields, function(k,v){
	    $( "#"+v ).val( data[v] );
    	$( "#badge_"+v ).html( data[v] );
	  })
    $('#contact_view').attr('href',"/civicrm/contact/view?cid="+data.contact_id);
    $('#participant_view').attr('href',"/civicrm/contact/view/participant?&id="+data.id+"&cid="+data.contact_id+"&action=view");
    $('input:submit').attr("disabled","disabled");
  };

  var qrcode = function (selector,contact) {
    var data= "BEGIN:VCARD\nVERSION:3.0\nFN:"+contact.first_name+" "+contact.last_name;
    if (contact.organization_name)
      data = data+"\nORG:"+contact.organization_name;
    if (contact.email)
      data = data + "\nEMAIL:"+contact.email;
    data = data + "\nUID:"+contact.contact_id+"\nEND:VCARD";
    if (data.length > 119)
      alert ("too bid, qrcode not working");
//34:4
//44:5
//58:6
//64:7
//84:8
//98:9
//119:10
data = "http://www.dutoit.info";
    jQuery(selector).html('').qrcode({text:data,width:78,height:78,typeNumber: 6,correctLevel: 0});
  };

  if (urlParams['debug']) {
    document.title = "Participant " + new Date();
    $('#restmsg').text('margin:'+margin);
    $('body').append ("<div id='all'></div>");
    $('body').append ("<div id='half'></div>");
    $('body').append ("<div id='b1'><img src='/"+ tttp_root+"/images/Badge/participant.jpg'/> </div>");
    $('body').append ("<div id='b2'><img src='/"+ tttp_root+"/images/Badge/participant.jpg'/> </div>");
    $('body').append ("<div id='b2'></div>");
  }

  $('#badge').addClass("fbadge").detach().appendTo('body');
  $('#message').detach().appendTo('body');
  $('body').append ("<div id='vbadge' class='vbadge'><img class='background' src='/" + tttp_root + "/images/Badge/participant.jpg' /></div>");
  setBackground (1);

  participants = $.map( participants, function( item ){ 
    item.value = item.last_name+","+item.first_name + " "+item.organization_name;
    return item;
  });

  if ( window.location.hash) {
    var participant_id = parseInt(window.location.hash.substr (1),10);
    var participant = $.grep(participants, function (item) {
      return item.id == participant_id;
    })[0];
    $('#participant').val(participant.value);
    setParticipant (participant);
  }

  $('#participant').autocomplete({
  minLength: 0,
  source:participants,
  autoFocus:true,
  open: function (event,ui) {
     $('.ui-autocomplete').css("z-index",1000000);
  },
  select: function( event, ui ) {
    setBackground(ui.item['role_id']);
    document.title = ui.item['last_name']+ " "+ ui.item['first_name'];
    window.location.hash = ui.item['id'];
    qrcode('#qrcode',ui.item);

    $.each(fields, function(k,v){
	    $( "#"+v ).val( ui.item[v] );
    	$( "#badge_"+v ).html( ui.item[v] );
	  })
//        return false;
	  }
  })
  .data( "autocomplete" )._renderItem = function( ul, item ) {
	  return $( "<li></li>" )
		.data( "item.autocomplete", item )
		.append( "<a class=role_"+item.role_id+" status_"+item.status_id+">" + item.last_name + ", "+item.first_name+"</a>" )
		.appendTo( ul );

  };

  $('#editor').submit(function() {//save the contact+email+participant+country
    var values={};
    var participant_id =$('#id').val();
    if (participant_id) {
      window.location.hash = participant_id;
    }
    $('#editor .dyn-field').each(function(){
      var v=$(this).val();
      if (v.length >0) {
        values[this.id] = v;
      }
    });
    if (participant_id) {
      var participant = $.grep(participants, function (item) {
        return item.id == participant_id;
      })[0];
    }

    // building the param for the ajax call
    if (values['country_id']) {
      values['api.address.create']= {"location_type_id":2,"country_id": values['country_id']};
      values['api.address.create']['is_primary']=1;
      if (participant_id && participant['address_id']) {
        values['api.address.create']['id']=participant['address_id'];
      } 
      delete values['country_id'];
    }
    if (values['email']) {
      values['api.email.create']= {"location_type_id":2,"email": values['email']};
      values['api.email.create']['is_primary']=1;
      if (participant_id && participant['email_id']) {
        values['api.email.create']['id'] =  participant['email_id'];
      }
      delete values['email'];
    }
    if (!participant_id)
      values ['api.participant.create'] = {"event_id":event_id,"role_id":$('#role_id').val(),"source":"live event"};
    if (values['contact_id']) {
      values['id'] = values['contact_id'];
      delete values['contact_id'];
    } else {
      values["source"] = "live event registration";
      values['contact_type'] = 'Individual';
    }
    
    //calling the ajax, chained
    $.ajax ('/civicrm/api/json',{
      type:"POST",
      dataType:"json", 
      data: {"entity":"contact","action":"create",params:JSON.stringify(values)},
      success:function (data) {
        if (data.is_error) {
          alert (data.error_message);
          return;
        }
        data=data.values[0];
        var participant={};
        participant.contact_id=data['id'];
        participant.last_name=data['last_name'];
        participant.first_name=data['first_name'];
        participant.organization_name=data['organization_name'];
        if (data['api.address.create']) {
          participant.address_id= data['api.address.create']['id'];
          participant.country_id= data['api.address.create']['values'][0]['country_id'];
        }
        if (data['api.email.create']) { 
          participant.email_id= data['api.email.create']['id'];
          participant.email= data['api.email.create']['values'][0]['email'];
        }
        if (data['api.participant.create']) {
          participant.id= data['api.participant.create']['id'];
          participant.status_id= data['api.participant.create']['values'][0]['status_id'];
          participant.role_id= data['api.participant.create']['values'][0]['role_id'];
          $('#participant').val (participant.last_name+', '+participant.first_name);
          $('#id').val (participant.id);
          participants.push(participant);
          //do we need to refresh the autocomplete?
          setParticipant(participant);
        }
      }
    });
    return false;
  });

$('.live-print').click(function() {
  if ($('#display_name').height() >50) {
     // name on two lines
     $('#display_name').css('top','45mm');
  } else {
     $('#display_name').css('top','50mm');
  }

  $('#vbadge').html($('#badge').html());
  if ($('#id').val() !="") {
    var participant_id=$('#id').val();
    var participant = $.grep(participants, function (item) {
      return item.id == participant_id;
    })[0];
    qrcode('#vbadge #qrcode',participant);
  }
  if (typeof jsPrintSetup == "object") {
     jsPrintSetup.setOption('footerStrLeft', '#'+$('#id').val());
     $('#restmsg').html( "printing on ..."+jsPrintSetup.getPrinter());
     jsPrintSetup.clearSilentPrint();
     jsPrintSetup.setOption('printSilent', 1);
     jsPrintSetup.print();
  } else {
     $('#restmsg').html( "No printer");
//    window.print()
  
}
  // flag as attended
  var id=$('#id').val();
  var status_id=2;
  $('#restmsg').html('<i>saving...</i>');
  cj().crmAPI('participant','create',{id:id,status_id:status_id}
    ,{'callBack':function(result,setting){
     contact_id=result.id;
  },'ajaxURL':options.ajaxURL});
});

$('.live-attended').click(function() {
  var id=$('#id').val();
  var status_id=2;
  $('#restmsg').html('<i>saving...</i>');
  cj().crmAPI('participant','create',{id:id,status_id:status_id}
    ,{'callBack':function(result,setting){
     contact_id=result.id;
     
//      if(result.is_error =1)
  
  },'ajaxURL':options.ajaxURL});
});

function setBackground (role_id) {
  $('#badge').removeClass();
  $('#vbadge').removeClass();
  $('#badge').addClass('fbadge role_'+role_id);
  $('#vbadge').addClass('vbadge role_'+role_id);
  $('#badge img').removeClass('active');
  $('#badge img.role_'+role_id).addClass('active');
  if ($('#badge img.role_'+role_id).length == 0) 
    $('#defaultimg').addClass('active');
}

$('#role_id').change(function(){
  setBackground ($(this).val());
  if ($('#id').val() >0) {
    cj().crmAPI('participant','create',{id:$('#id').val(),role_id:$(this).val()}
      ,{'callBack':function(result,setting){
//      if(result.is_error =1)
     },'ajaxURL':options.ajaxURL}); 
  }
});

$('#country_id').change(function(){
  $('#badge_country').html($('#country_id option:selected').text());
  $('input:submit').removeAttr("disabled");
});

$('#participant_search').submit(function() {
  var participant_id=$('#id').val();
  var participant = $.grep(participants, function (item) {
    return item.id == participant_id;
  })[0];
  if (!participant) {
    alert ("not found");
  }
 
  $('#participant').val(participant.value);
  setParticipant (participant);
  $('input:submit').attr("disabled","disabled");
  return false;
});

$('disable #last_name').blur(function() {
 if (!$('contact_id').val()) {
   cj().crmAPI('Contact','get',{'contact_type':'Individual','last_name':$('#last_name').val()+"%",'return':"contact_id,last_name,first_name,sort_name,current_employer,country_id,country,email"},
     {'callBack':function(result,setting) {
       if (result.count=0)
         return;
       $('#found_contacts').show();
       html ='';
       $.each(result.values, function(k,v){
          html = html + "<li data-contact_id='"+v.contact_id+"' data-address_id='"+v.address_id+ "' data-country_id='"+v.country_id+"' data-email='"+v.email+"'><span class='last_name'>"+v.last_name
  +"</span>, <span class='first_name'>"+v.first_name + '</span> <span class="organization_name">'+ v.current_employer
  +'</span></li>';
       });
       $('#list_contact').html(html);
       $('#list_contact li').click(function(){
         $('#contact_id').val($(this).data('contact_id'));
         $('#email').val($(this).data('email'));
         $('#country_id').val($(this).data('country_id'));
         $('#address_id').val($(this).data('address_id'));
         $('#first_name').val($(this).find('.first_name').text());
         $('#last_name').val($(this).find('.last_name').text());
         $('#organization_name').val($(this).find('.organization_name').text());
         $('#editor .dyn-field').each (function(){
           $('#badge_'+this.id).html($(this).val());
         });

       });
     },'ajaxURL':options.ajaxURL}
   );
 }
});

  $('.live-edit').click(function() {$('#editor').fadeIn();});
  $('.live-new').click(function() {
    $('#participant').val('');
    $('.dyn-field').val('')
    $('.dyn-badge').html('')
  });

  $('.dyn-field').keyup(function() { // .change doesn't work?
   $('#badge_'+this.id).html($(this).val());
   $('input:submit').removeAttr("disabled");
  });
  //$('#editor').hide();
  $('#found_contacts').hide();

  if (typeof jsPrintSetup == "object") {
     jsPrintSetup.setOption('orientation', jsPrintSetup.kPortraitOrientation);
  //eventually do something with it
  //jsPrintSetup.getPrintersList();
  //setPrinter(in wstring aPrinterName);
     jsPrintSetup.setPaperSizeData(9);
     jsPrintSetup.setOption('shrinkToFit', false);
     jsPrintSetup.setOption('printRange', jsPrintSetup.kRangeSpecifiedPageRange);
     jsPrintSetup.setOption('startPageRange', 1);
     jsPrintSetup.setOption('endPageRange', 1);
     jsPrintSetup.setOption('marginTop', margin[0]);
     jsPrintSetup.setOption('marginRight', margin[1]);
     jsPrintSetup.setOption('marginBottom', margin[2]);
     jsPrintSetup.setOption('marginLeft', margin[3]);
     jsPrintSetup.setOption('headerStrLeft', "Help spread the news");
     jsPrintSetup.setOption('headerStrCenter', '');
  //   jsPrintSetup.setOption('headerStrRight', 'Twitter hashtag');
     jsPrintSetup.setOption('footerStrLeft', '');
     jsPrintSetup.setOption('footerStrCenter', 'Thanks for your participation');
  //   jsPrintSetup.setOption('footerStrRight', 'http://www.pes.org/site');
     jsPrintSetup.clearSilentPrint();
     jsPrintSetup.setOption('printSilent', 1);
     // Do Print 
     // When print is submitted it is executed asynchronous and
     // script flow continues after print independently of completetion of print process! 
   //  jsPrintSetup.print();
     // next commands
  } else {
      $('#restmsg').html('<h2>For best results, use Firefox and install <a href="http://jsprintsetup.mozdev.org/">jsprintsetup</a></h2>');
  }

});

{/literal}
</script>
<div id="message">
Please do keep your badge for the duration of the event
</div>

<div id='crm-container' class='live_event'>
<div>
<div id="restmsg">&nbsp;</div>
name 
	<input name="participant" id="participant" class="ac_input" />
({$total} participants)
<form id="participant_search">
<label>ID</label>
<input id="id" type="text" value="" class="dyn-field"></form>
	</div>
	<ul class='crm-actions-ribbon'><li class='crm-button live-attended'><span>Attended!</span></li>
	<li  class='crm-button live-print'><span>Print</span></li>
	<li  class='crm-button live-new'><span>New</span></li>
	<!--li class='crm-button live-edit'><span>Edit</span></li-->
</ul>
<div id="badge">
<div id="qrcode" class="dyn-badge"></div>
<img class='background role_1' id="defaultimg" src='/{$tttp_root}/images/Badge/participant.gif' />

<div id="display_name"><span id="badge_first_name" class="dyn-badge"></span> <span id="badge_last_name" class="dyn-badge"></span></div>
<div id="second"><span id="badge_organization_name" class="dyn-badge"></span><span class='separator'>,</span><br><span id="badge_country" class="dyn-badge"></span></div>
<div id="badge_id" class="dyn-badge"></div>
</div>


<form id="editor" action='#'>
<select id='role_id'>
{foreach from=$role  item=role}
<option id="role_{$role->value}" value="{$role->value}">{$role->label}</option>
{/foreach}
</select><br/>
<input id="contact_id" type="hidden" class="dyn-field" />
<input name="address" type="hidden" id="address_id" class="adyn-field" />
<label>First name</label>
<input id="first_name" class="dyn-field"/>
<label>Last name</label>
<input id="last_name" class="dyn-field"/>
<div id="found_contacts">Is this the contact?<ul id="list_contact"></ul></div>
<label>Organisation</label>
<input id="organization_name" class="dyn-field"/>
<label>Email</label>
<input id="email" class="dyn-field" />
<label>Country</label><br/>
{crmAPI var="Countries" entity="Constant" action="get" version="3" name="country" }
<select name="country" id="country_id" class="dyn-field">
<option value="">(choose)</option>
{foreach from=$Countries.values key=id item=country}
<option value="{$id}">{$country}</option>
{/foreach}
</select>
<input type='submit' value="Save"  disabled="disabled"/>
</form>

<ul id="toolview">
<li><a href="" id="participant_view" target="_blank">Participant</a></li>
<li><a href="" id="contact_view" target="_blank">Contact</a></li>
</ul>
</div>
