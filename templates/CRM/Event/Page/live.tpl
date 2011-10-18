{literal}
<style>
  #badge {border:1px solid;width:100mm;height:70mm;position:relative;margin-top:10mm}
  #display_name {font-size:20px;margin-top:20mm;text-align:center;}
  #second{font-size:15px;;margin-top:10mm;text-align:center;}

@media print {
    * { display:hidden; }
    #badge {display:block;}
  }
  
</style>
{/literal}
<script>
var participants={$participants_json}
{literal}
jQuery(function($){
      //source:['aa','bbb','ccc'],
  $('#participant').autocomplete({
      minLength: 0,
source:participants,
      focus: function( event, ui ) {
        $( "#display_name" ).val( ui.item.display_name );
        return false;
      },
      select: function( event, ui ) {
        $( "#display_name" ).html( ui.item.display_name );
        $( "#second" ).html('Org, Country');
        window.print();
//        return false;
      },

})
    .data( "autocomplete" )._renderItem = function( ul, item ) {
      return $( "<li></li>" )
        .data( "item.autocomplete", item )
        .append( "<a>" + item.display_name + "</a>" )
        .appendTo( ul );
    };

;
});
{/literal}
</script>

Type the name 
<input name="participant" id="participant" />
<div id="badge">
<div id="display_name">Display name</div>
<div id="second">2nd line</div>
</div>



