{*
 +--------------------------------------------------------------------+
 | CiviCRM version 3.3                                                |
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC (c) 2004-2010                                |
 +--------------------------------------------------------------------+
 | This file is a part of CiviCRM.                                    |
 |                                                                    |
 | CiviCRM is free software; you can copy, modify, and distribute it  |
 | under the terms of the GNU Affero General Public License           |
 | Version 3, 19 November 2007 and the CiviCRM Licensing Exception.   |
 |                                                                    |
 | CiviCRM is distributed in the hope that it will be useful, but     |
 | WITHOUT ANY WARRANTY; without even the implied warranty of         |
 | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               |
 | See the GNU Affero General Public License for more details.        |
 |                                                                    |
 | You should have received a copy of the GNU Affero General Public   |
 | License and the CiviCRM Licensing Exception along                  |
 | with this program; if not, contact CiviCRM LLC                     |
 | at info[AT]civicrm[DOT]org. If you have questions about the        |
 | GNU Affero General Public License or the licensing of CiviCRM,     |
 | see the CiviCRM license FAQ at http://civicrm.org/licensing        |
 +--------------------------------------------------------------------+
*}
{if $context EQ 'Search'}
    {include file="CRM/common/pager.tpl" location="top"}
{/if}
<script type="text/javascript" charset="utf-8" src='{$config->userFrameworkResourceURL}/packages/jquery/plugins/jquery.dataTables.min.js'></script>
<script type="text/javascript" charset="utf-8" src="{$tabletool}/ZeroClipboard/ZeroClipboard.js"></script>
<script type="text/javascript" charset="utf-8" src="{$tabletool}/js/TableTools.js"></script>

<script>
  TableToolsInit.sSwfPath = '{$tabletool}/swf/ZeroClipboard.swf'; 
{literal}
   $(function($){
      var aoColumns = [];
      $('table.selector thead th').each(function (){
        if ($(this).hasClass('sort')) {
          aoColumns.push(null);
        } else {
          aoColumns.push({ "bSortable": false });
        }
      });
      $('table.selector').dataTable(
         {'bPaginate': false,
          'asStripClasses': [],
          'bJQueryUI': true,
           'sDom': 'T<\"clear\">lfrt',
           'aaSorting':[],
           'aoColumns': aoColumns  }); 

    $("a.action-badge").click (function(){
      $(this).attr({ target: "_blank" });
      return true;
    });
    $("td.crm-participant_participant_status-1")
    .attr("title","Change the status to completed")
    .css("cursor","pointer")
    .click (function () {
      aid=$(this).parent("tr").attr('id');
      var activity_id = aid.replace("crm-activity_", "");
      cj().crmAPI ('activity','update',{id:activity_id,status_id:2}, 
       {callBack: function(result,settings){
          if (result.is_error == 1) {
            $(settings.msgbox)
            .addClass('msgnok')
            .html(result.error_message);
            return false;
          } else {
            $('#crm-activity_'+activity_id)
            .find('td.crm-activity-status_1')
            .removeClass('crm-activity-status_1')
            .addClass('crm-activity-status_2')
            .html("Completed"); 
          }
        }
       });
    });

   });
 </script>
  <link type='text/css' rel='stylesheet' media='screen'  href='{/literal}{$tabletool}{literal}/css/TableTools.css'></link>
  <style media='screen'>.selector th {padding-right:16px} .ui-icon {float:left;}</style>
{/literal}
{*debug}
*}
{strip}
<table class="selector">
<thead class="sticky">
    <tr>
    {if ! $single and $context eq 'Search' }
      <th scope="col" title="Select Rows">{$form.toggleSelect.html}</th> 
    {/if}
    {if $context EQ 'Search'}
        <th></th>
        <th class='sort'>Country</th>
        <th class='sort'>Organisation</th>
        <th class='sort'>Participant</th>
    {/if}
    {if $displayEvent}
        <th class='sort'>Event</th>
        <th>Event Date</th>
    {/if}
    {if $displayFee}
        <th class='sort'>Fee level</th>
        <th class='sort'>Amount</th>
    {/if}
        <th>Registered</th>
        <th class='sort'>Status</th>
        <th class='sort'>Role</th>
        <th>Actions</th>
    {*foreach from=$columnHeaders item=header}
        <th scope="col">
        {if $header.sort}
          {assign var='key' value=$header.sort}
          {$sort->_response.$key.link}
        {else}
          {$header.name}
        {/if}
        </th>
    {/foreach*}
    </tr>
 </thead>

  {counter start=0 skip=1 print=false}
  {foreach from=$rows item=row}
  <tr id='crm-participant_{$row.participant_id}' class="{cycle values="odd-row,even-row"} crm-event crm-event_{$row.event_id}">
     {if ! $single} 
     {if  $context eq 'Search' }       
            {assign var=cbName value=$row.checkbox}
            <td>{$form.$cbName.html}</td> 
        {/if}
     {/if}
     {if  $context eq 'Search' }       
      	<td class="crm-participant-contact_type">{$row.contact_type}</td>
        <td class="country_{$row.country_id}">{$row.country}</td>
        <td ><a href="{crmURL p='civicrm/contact/view' q="reset=1&cid=`$row.employer_id`"}">{$row.employer}</a></td>
    	<td class="crm-participant-sort_name"><a href="{crmURL p='civicrm/contact/view' q="reset=1&cid=`$row.contact_id`"}" title="{ts}View contact record{/ts}">{$row.sort_name}</a></td>
    {/if}

    {if $displayEvent}
      <td class="crm-participant-event_title"><a href="{crmURL p='civicrm/event/info' q="id=`$row.event_id`&reset=1"}" title="{ts}View event info page{/ts}">{$row.event_title}</a>
     </td> 
      <td class="crm-participant-event_start_date">{$row.event_start_date|truncate:10:''|crmDate}
          {if $row.event_end_date && $row.event_end_date|date_format:"%Y%m%d" NEQ $row.event_start_date|date_format:"%Y%m%d"}
              <br/>- {$row.event_end_date|truncate:10:''|crmDate}
          {/if}
      </td>
    {/if}
    {assign var="participant_id" value=$row.participant_id}
    {if $displayFee}
      {if $lineItems.$participant_id}
          <td class="crm-participant-participant_fee_level">
          {foreach from=$lineItems.$participant_id item=line name=lineItemsIter}
        {if $line.html_type eq 'Text'}{$line.label}{else}{$line.field_title} - {$line.label}{/if}: {$line.qty}
              {if ! $smarty.foreach.lineItemsIter.last}<br />{/if}
          {/foreach}
          </td>
    {else}
        <td class="crm-participant-participant_fee_level">{if !$row.paid && !$row.participant_fee_level} {ts}(no fee){/ts}{else} {$row.participant_fee_level}{/if}</td>
    {/if}
        <td class="right nowrap crm-paticipant-participant_fee_amount">{$row.participant_fee_amount|crmMoney:$row.participant_fee_currency}</td>
    {/if}
    <td class="crm-participant-register_date">{$row.participant_register_date|truncate:10:''|crmDate}</td>	
    <td class="crm-participant-status crm-participant_status_id-{$row.participant_status_id}">{$row.participant_status}</td>
    <td class="crm-participant-participant_role">{$row.participant_role_id}</td>
    <td><a title="Print Event Name Badge" class="action-item action-badge" href="{crmURL p='civicrm/event/badge' q="context=view&reset=1&cid=`$row.contact_id`&id=`$participant_id`"}"><span class="icon print-icon"></span></a>  
{$row.action|replace:'xx':$participant_id}</td>
   </tr>
  {/foreach}
{* Link to "View all participants" for Dashboard and Contact Summary *}
{if $limit and $pager->_totalItems GT $limit }
  {if $context EQ 'event_dashboard' }
    <tr class="even-row">
    <td colspan="10"><a href="{crmURL p='civicrm/event/search' q='reset=1'}">&raquo; {ts}Find more event participants{/ts}...</a></td></tr>
    </tr>
  {elseif $context eq 'participant' }  
    <tr class="even-row">
    <td colspan="7"><a href="{crmURL p='civicrm/contact/view' q="reset=1&force=1&selectedChild=participant&cid=$contactId"}">&raquo; {ts}View all events for this contact{/ts}...</a></td></tr>
    </tr>
  {/if}
{/if}
</table>
{/strip}

{if $context EQ 'Search'}
 <script type="text/javascript">
 {* this function is called to change the color of selected row(s) *}
    var fname = "{$form.formName}";	
    on_load_init_checkboxes(fname);
 </script>
{/if}

{if $context EQ 'Search'}
    {include file="CRM/common/pager.tpl" location="bottom"}
{/if}
