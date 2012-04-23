<?

function civicrm_api3_participant_getfull ($param) {
  $query= "SELECT civicrm_participant.id, event_id,civicrm_participant.contact_id,status_id, role_id,first_name,last_name, job_title, organization_name, employer_id, civicrm_address.id as address_id, civicrm_country.id as country_id, civicrm_country.name as country
    FROM civicrm_participant 
    JOIN civicrm_contact on civicrm_contact.id= civicrm_participant.contact_id 
    LEFT JOIN civicrm_address on civicrm_address.contact_id = civicrm_contact.id and is_primary=1 
    LEFT JOIN civicrm_country on civicrm_country.id = country_id 
    LEFT JOIN civicrm_email ON civicrm_email.contact_id = civicrm_participant.contact_id AND civicrm_email.is_primary=1";
  if (array_key_exists ('event_id',$param)) {
    $event_id= (int) $param['event_id'] ;
    $query .= " WHERE event_id = $event_id";
  }
  if (array_key_exists ('option.limit',$param)) {
    $limit = (int) $param['option.limit'];
  } else {
    $limit = 25;
  }
  $query .= " LIMIT $limit";
  

  $dao = CRM_Core_DAO::executeQuery( $query );
  $r = array ();
  while ($dao->fetch( ) ) {
    $r[] = $dao->toArray();
  }
  return civicrm_api3_create_success ($r,$param,'','',$dao);
}
