{literal}
<style>
#badge {border:1px solid;width:100mm;height:70mm;position:relative;margin-top:10mm}
#display_name {font-size:20px;margin-top:20mm;text-align:center;}
#second{font-size:15px;;margin-top:10mm;text-align:center;}
#editor input {display:block;}
#editor {position:absolute;top:0;left:400px}
.live_event {position:relative;}
#crm-container .ac_input {width:10em}
@media print {
	* { display:hidden; }
#badge {display:block;}
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

  var fields=['first_name','last_name','country', 'country_id','organization_name','employer_id','id','contact_id','role_id'];

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
          html = html + "<li data-contact_id='"+v.contact_id+"' data-country_id='"+v.country_id+"'><span class='last_name'>"+v.last_name
  +"</span>, <span class='first_name'>"+v.first_name + '</span> <span class="organization_name">'+ v.current_employer
  +'</span></li>';
//        	$( "#"+v ).val( ui.item[v] )
       });
       $('#list_contact').html(html);
       $('#list_contact li').click(function(){
         $('#contact_id').val($(this).data('contact_id'));
         $('#country_id').val($(this).data('country_id'));
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
<input id="id" type="" value="" class="dyn-field">
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
<div id="display_name"><span id="badge_first_name"></span> <span id="badge_last_name"></span></div>
<div id="second"><span id="badge_organization_name"></span> ,<span id="badge_country"></span></div>
</div>


<form id="editor">
<input id="contact_id" class="dyn-field" />
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
