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

</style>
{/literal}
<script>
var participants={$participants_json};
{literal}
jQuery(function($){

  var fields=['first_name','last_name','country','current_employer','current_employer_id','id','contact_id','role_id'];

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

$('.live-print').click(function() {window.print()});
$('.live-edit').click(function() {$('#editor').fadeIn();});
$('.live-new').click(function() {$('#editor').fadeIn();$('.dyn-field').val('')});
$('.dyn-field').keyup(function() { // .change doesn't work?
		$('#badge_'+this.id).html($(this).val());
		});
$('#editor').hide();
;
});
{/literal}
</script>
<div id='crm-container' class='live_event'>
<div>
name 
	<input name="participant" id="participant" class="ac_input" />
({$total} participants)
	</div>
	<ul class='crm-actions-ribbon'><li class='crm-button'><span>Attended!</span></li>
	<li  class='crm-button live-print'><span>Print</span></li>
	<li  class='crm-button live-new'><span>New</span></li>
	<li class='crm-button live-edit'><span>Edit</span></li>
	<li> <select id='crm-participant-status'>
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
<label>Last name</label>
<input id="last_name" class="dyn-field"/>
<label>First name</label>
<input id="first_name" class="dyn-field"/>
<label>Organisation</label>
<input id="organization_name" class="dyn-field"/>
<label>Email</label>
<input id="email" class="dyn-field"/>
<label>Country</label>
<input id="country" class="dyn-field"/>
<input type='submit' value="Save"/>
</div>
