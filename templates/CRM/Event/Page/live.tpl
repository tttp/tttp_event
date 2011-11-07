{literal}
<style>
#badge {border:1px solid;width:97mm;height:86mm;position:relative;margin-top:10mm;
}
#badge .background {display:block;position:absolute;left:0;top:0;width:100%;height:100%;z-index:1}



#display_name {display:absolute;font-size:20px;margin-top:20mm;text-align:left;z-index:10;position:relative;
left:10mm;top:30mm;
}
#second{font-size:15px;top:60mm;
left:10mm;
text-align:left;z-index:10;position:absolute;}
#editor input {display:block;}
#editor {position:absolute;top:0;left:400px}
.live_event {position:relative;}
#crm-container .ac_input {width:10em}
.ui-widget-content {background:white}

#crm-container .crm-actions-ribbon li {padding:2px 10px;}

#wrapper {height:100%;width:100%;border:1px solid pink;}

@media print {
	* { visibility:hidden;color:yellow;position:inherit;text-shadow:none;}
  .crm-button {border:none!important;}

h1 {text-shadow:none;}

  #logo {display:none;}
  #wrapper {position:inherit;}

  input {display:none;visibility:hidden;}
/* 297-86 -10 = 201mm */
   #badge {display:block;position:absolute;top:201mm;left:0;visibility:visible;}
#badge * {display:block;visibility:visible;color:black;margin:0;}

#wrapper {height:297mm;width:210mm; border:2px solid green;left:0;top:0;}
}

.status_1 {}
.status_2 {font-weight:bold;}
</style>
{/literal}
<script>
var participants={$participants_json};
var event_id={$event->id};
{literal}
jQuery(function($){

  var fields=['first_name','last_name','country', 'country_id','organization_name','employer_id','id','contact_id','role_id','address_id'];

     //label: item.name + (item.adminName1 ? ", " + item.adminName1 : "") + ", " + item.countryName,
  participants = $.map( participants, function( item ){ 
    item.value = item.last_name+","+item.first_name;
    return item;
  });
  //source:['aa','bbb','ccc'],
  $('#participant').autocomplete({
  minLength: 0,
  source:participants,
  select: function( event, ui ) {
    $.each(fields, function(k,v){
	$( "#"+v ).val( ui.item[v] );
	$( "#badge_"+v ).html( ui.item[v] );
	});
//        return false;
	}
  })
    //item.label = "<span class=role_"+item.role_id+" status_"+item.status_id+">"+item.first_name+" "+item.last_name+"</span>";
.data( "autocomplete" )._renderItem = function( ul, item ) {
	return $( "<li></li>" )
		.data( "item.autocomplete", item )
		.append( "<a class=role_"+item.role_id+" status_"+item.status_id+">" + item.last_name + ", "+item.first_name+"</a>" )
		.appendTo( ul );

};

$('#editor').submit(function() {
 //var values={'contact_type':'Individual'};
 var values={};
 $('#editor .dyn-field').each(function(){
    values[this.id] = $(this).val();
 });
 if (values['contact_id'])
   values['id']=values['contact_id'];
 else
   values['contact_type'] = 'Individual';

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
     }});
    }
  });

 return false;
});
$('.live-print').click(function() {window.print()});
$('.live-attended').click(function() {
  var id=$('#id').val();
  var status_id=2;
  $('#restmsg').html('<i>saving...</i>');
  cj().crmAPI('participant','create',{id:id,status_id:status_id}
    ,{'callBack':function(result,setting){
     contact_id=result.id;
     
//      if(result.is_error =1)
  
  }});
});
$('#role_id').change(function(){
  cj().crmAPI('participant','create',{id:$('#id').val(),role_id:$(this).val()}
    ,{'callBack':function(result,setting){
//      if(result.is_error =1)
  }}); 
});
$('#country_id').change(function(){
 $('#badge_country').html($('#country_id option:selected').text());
 var address_id = $('#address_id').val();
 if (address_id) 
   cj().crmAPI('Address','update',{'id':address_id,'country_id':$('#country_id').val()});
 else 
   $('#restmsg').html('Country not saved');
}); 

$('#last_name').blur(function() {
 if (!$('contact_id').val()) {
   cj().crmAPI('Contact','get',{'contact_type':'Individual','last_name':$('#last_name').val()+"%",'return':"contact_id,last_name,first_name,sort_name,current_employer,country_id,country"},
     {'callBack':function(result,setting) {
       if (result.count=0)
         return;
       $('#found_contacts').show();
       html ='';
       $.each(result.values, function(k,v){
          html = html + "<li data-contact_id='"+v.contact_id+"' data-address_id='"+v.address_id+ "' data-country_id='"+v.country_id+"'><span class='last_name'>"+v.last_name
  +"</span>, <span class='first_name'>"+v.first_name + '</span> <span class="organization_name">'+ v.current_employer
  +'</span></li>';
//        	$( "#"+v ).val( ui.item[v] )
       });
       $('#list_contact').html(html);
       $('#list_contact li').click(function(){
         $('#contact_id').val($(this).data('contact_id'));
         $('#country_id').val($(this).data('country_id'));
         $('#address_id').val($(this).data('address_id'));
         $('#first_name').val($(this).find('.first_name').text());
         $('#last_name').val($(this).find('.last_name').text());
         $('#organization_name').val($(this).find('.organization_name').text());
         $('#editor .dyn-field').each (function(){
           $('#badge_'+this.id).html($(this).val());
         });

       });
     }}
   );
 }
});
$('.live-edit').click(function() {$('#editor').fadeIn();});
$('.live-new').click(function() {$('#editor').fadeIn();$('.dyn-field').val('')});
$('.dyn-field').keyup(function() { // .change doesn't work?
 $('#badge_'+this.id).html($(this).val());
});
$('#editor').hide();
$('#found_contacts').hide();

});
{/literal}
</script>
<div id='crm-container' class='live_event'>
<div>
<div id="restmsg">&nbsp;</div>
name 
	<input name="participant" id="participant" class="ac_input" />
({$total} participants)
<input id="id" type="hidden" value="" class="dyn-field">
	</div>
	<ul class='crm-actions-ribbon'><li class='crm-button live-attended'><span>Attended!</span></li>
	<li  class='crm-button live-print'><span>Print</span></li>
	<li  class='crm-button live-new'><span>New</span></li>
	<li class='crm-button live-edit'><span>Edit</span></li>
	<li> <select id='role_id'>
{foreach from=$role  item=role}
<option id="role_{$role->value}" value="{$role->value}">{$role->label}</option>
{/foreach}
</select></li>
</ul>
<div id="badge">

<img class='background' src='/{$tttp_root}/images/Badge/participant.jpg' />

<div id="display_name"><span id="badge_first_name">AAA</span> <span id="badge_last_name"></span></div>
<div id="second"><span id="badge_organization_name">BB</span> ,<span id="badge_country"></span></div>
</div>


<form id="editor">
<input id="contact_id" type="hidden" class="dyn-field" />
<input name="address" id="address_id" class="adyn-field" />
<label>Last name</label>
<input id="last_name" class="dyn-field"/>
<div id="found_contacts">Is this the contact?<ul id="list_contact"></ul></div>
<label>First name</label>
<input id="first_name" class="dyn-field"/>
<label>Organisation</label>
<input id="organization_name" class="dyn-field"/>
<!--label>Email</label>
<input id="email" class="dyn-field"/-->
<label>Country</label><br/>
{crmAPI var="Countries" entity="Constant" action="get" version="3" name="country" }
<select name="country" id="country_id" class="adyn-field">
<option value="">(choose)</option>
{foreach from=$Countries.values key=id item=country}
<option value="{$id}">{$country}</option>
{/foreach}
</select>
<input type='submit' value="Save"/>
</div>
