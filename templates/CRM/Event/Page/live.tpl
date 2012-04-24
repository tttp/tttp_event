{literal}
<style>

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


#display_name {display:block;font-size:20px;top:50mm;text-align:left;z-index:10;
left:10mm;
position:absolute;
}
#second{font-size:15px;top:60mm;
left:10mm;
text-align:left;z-index:10;position:absolute;}
.separator, #aabadge_country {display:none;}

#editor input {display:block;}
#editor {position:absolute;top:100px;left:0px}
.live_event {position:relative;}
#crm-container .ac_input {width:10em;z-index:20}

.ui-autocomplete {background:white;z-index:10000;}

#crm-container .crm-actions-ribbon li {padding:2px 10px;}

#wrapper {height:100%;width:100%;border:1px solid pink;}

@media screen {
  #badge {border:1px solid;width:97mm;height:86mm;position:absolute;top:300px;left:555px;}
  #vbadge {visibility:hidden;position:absolute;top:300px;left:555px;height:1px;width:1px;}
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
  .vbadge {left:auto;right:0;} */

  

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

jQuery(function($){

  var fields=['first_name','last_name','country', 'country_id','organization_name','employer_id','id','contact_id','email','role_id','address_id'];

  if (urlParams['debug']) {
    document.title = "Participant " + new Date();
    $('#restmsg').text('margin:'+margin);
    $('body').append ("<div id='all'></div>");
    $('body').append ("<div id='half'></div>");
    $('body').append ("<div id='b1'><img src='/"+ tttp_root+"/images/Badge/tech.jpg'/> </div>");
    $('body').append ("<div id='b2'><img src='/"+ tttp_root+"/images/Badge/staff.jpg'/> </div>");


    $('body').append ("<div id='b2'></div>");
  }

//('body').append ("<div id='fbadge'><img class='background' src='/" + tttp_root + "/images/Badge/participant.jpg' /></div>");
//$('body').append ("<div class='fbadge'><img class='background' src='/" + tttp_root + "/images/Badge/participant.jpg' /></div>");
//$('.fbadge').appendTo ("body");
  $('#badge').addClass("fbadge").detach().appendTo('body');
  $('#message').detach().appendTo('body');
  $('body').append ("<div id='vbadge' class='vbadge'><img class='background' src='/" + tttp_root + "/images/Badge/participant.jpg' /></div>");
  setBackground (1);

  participants = $.map( participants, function( item ){ 
    item.value = item.last_name+","+item.first_name;
    return item;
  });

  $('#participant').autocomplete({
  minLength: 0,
  source:participants,
  open: function (event,ui) {
     $('.ui-autocomplete').css("z-index",1000000);
  },
  select: function( event, ui ) {
    setBackground(ui.item['role_id']);
    document.title = ui.item['last_name']+ " "+ ui.item['first_name'];
    window.location.hash = ui.item['id'];
    jQuery('#qrcode').html('').qrcode({text:document.URL,width:78,height:78});

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

$('#editor').submit(function() {
   var values={};
    window.location.hash = ui.item['id'];
   jQuery('#qrcode').html('').qrcode({text:document.URL,width:78,height:78});
   $('#editor .dyn-field').each(function(){
      var v=$(this).val();
      if (v.length >0) {
        values[this.id] = v;
      }
   });
   if (values['contact_id'])
     values['id']=values['contact_id'];
   else
     values['contact_type'] = 'Individual';
//http://34.crm/civicrm/api/json?{%22entity%22:%22contact%22,%22action%22:%22create%22,%22contact_type%22:%22Individual%22,%22email%22:%22test@gogo.com%22,%22api.participant.create%22:{%22status_id%22:1,%22role_id%22:1,%22event_id%22:5},%22api.address.create%22:{%22location_type_id%22:1,%22country_id%22:1020}}
   var address = {'location_type_id':1};
   if (values['address_id'])
     address['id']=values['address_id'];
   address['country_id']=values['country__id'];
   values['api.address.create'];

   cj().crmAPI('contact','create',values,
    {'callBack': function(re,opt){
       var contact_id=re.id;
       var participant_id=$('#id').val();
       if (participant_id) {
         return;
       }

       cj().crmAPI('participant','create',{'event_id': event_id, 'contact_id':contact_id,'status_id':2,'role_id':$('#role_id').val()},
       {'callBack': function(re,opt){
          $('#id').val(re.id);
       },'ajaxURL':options.ajaxURL});
      }

    });

   return false;
});

$('.live-print').click(function() {
  jsPrintSetup.setOption('footerStrLeft', '#'+$('#id').val());
  if ($('#display_name').height() >50) {
     // name on two lines
     $('#display_name').css('top','45mm');
  } else {
     $('#display_name').css('top','50mm');
  }

  $('#vbadge').html($('#badge').html());
  if (typeof jsPrintSetup == "object") {
     $('#restmsg').html( "printing on ..."+jsPrintSetup.getPrinter());
     jsPrintSetup.clearSilentPrint();
     jsPrintSetup.setOption('printSilent', 1);
     jsPrintSetup.print();
  } else {
    window.print()}
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
$('.live-new').click(function() {$('#editor').fadeIn();$('.dyn-field').val('')});
$('.dyn-field').keyup(function() { // .change doesn't work?
 $('#badge_'+this.id).html($(this).val());
});
//$('#editor').hide();
$('#found_contacts').hide();

});


if (typeof jsPrintSetup == "object") {
   // set portrait orientation
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
   // set page header
   jsPrintSetup.setOption('headerStrLeft', "Help spread the news");
   jsPrintSetup.setOption('headerStrCenter', '');
   jsPrintSetup.setOption('headerStrRight', 'Twitter hashtag');
   // set empty page footer
   jsPrintSetup.setOption('footerStrLeft', '');
   jsPrintSetup.setOption('footerStrCenter', 'Thanks for your participation');
//   jsPrintSetup.setOption('footerStrRight', 'http://www.pes.org/renew');
   // clears user preferences always silent print value
   // to enable using 'printSilent' option
   jsPrintSetup.clearSilentPrint();
   // Suppress print dialog (for this context only)
   jsPrintSetup.setOption('printSilent', 1);
   // Do Print 
   // When print is submitted it is executed asynchronous and
   // script flow continues after print independently of completetion of print process! 
 //  jsPrintSetup.print();
   // next commands
}
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
<label>ID</label>
<input id="id" type="text" value="" class="dyn-field">
	</div>
	<ul class='crm-actions-ribbon'><li class='crm-button live-attended'><span>Attended!</span></li>
	<li  class='crm-button live-print'><span>Print</span></li>
	<li  class='crm-button live-new'><span>New</span></li>
	<!--li class='crm-button live-edit'><span>Edit</span></li-->
</ul>
<div id="badge">
<div id="qrcode"></div>
<img class='background role_1' id="defaultimg" src='/{$tttp_root}/images/Badge/participant.gif' />

<div id="display_name"><span id="badge_first_name"></span> <span id="badge_last_name"></span></div>
<div id="second"><span id="badge_organization_name"></span><span class='separator'>,</span><br><span id="badge_country"></span></div>
</div>


<form id="editor">
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
<input type='submit' value="Save"/>
</div>
