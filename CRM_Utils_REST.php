Index: CRM/Utils/REST.php
===================================================================
--- CRM/Utils/REST.php	(revision 38908)
+++ CRM/Utils/REST.php	(working copy)
@@ -449,26 +449,60 @@
    * works both as GET or POST
    **/
   static function ajaxJson () {
-    if (!empty ($_POST)) 
-      $params = $_POST;
-    else 
-      $params = $_GET;
-
-    foreach ($params as $k => $v) {
-      if ($k[0] == '{')  {
-        $p=stripslashes($k);
-        $a_params = json_decode (stripslashes($p),true);
-        if (is_array($a_params)) {
-          $_REQUEST = $a_params;
-          $_REQUEST['json'] = 1;
-          CRM_Utils_REST::ajax();
-          return;
-        }
+    require_once 'api/v3/utils.php';
+    if ( !$config->debug && ( ! array_key_exists ( 'HTTP_X_REQUESTED_WITH',$_SERVER ) ||
+      $_SERVER['HTTP_X_REQUESTED_WITH'] != "XMLHttpRequest" ) ) {
+      $error =
+        civicrm_api3_create_error( "SECURITY ALERT: Ajax requests can only be issued by javascript clients, eg. $().crmAPI().",
+          array( 'IP'      => $_SERVER['REMOTE_ADDR'],
+          'level'   => 'security',
+          'referer' => $_SERVER['HTTP_REFERER'],
+          'reason'  => 'CSRF suspected' ) );
+      echo json_encode( $error );
+      CRM_Utils_System::civiExit( );
+    }
+    if (empty ($_REQUEST['entity'])) {
+      echo json_encode(civicrm_api3_create_error( 'missing entity param'));
+      return;
+    }
+    if (empty ($_REQUEST['entity'])) {
+      echo json_encode(civicrm_api3_create_error( 'missing entity entity'));
+      return;
+    }
+    if (empty ($_REQUEST['params'])) {
+      if ($_POST[0] == '{')  {
+        $params = json_decode($_POST);
+      } else {
+        echo json_encode(civicrm_api3_create_error( 'missing entity params (as json'));
+        return;
       }
+    } else {
+      $params = json_decode($_REQUEST['params'],true);
     }
-    require_once 'api/v3/utils.php';
-    civicrm_api3_create_error( 'missing json param, eg: /civicrm/api/json?{"entity":"Contact","action":"Get"}');
+
+    $entity = CRM_Utils_String::munge(CRM_Utils_Array::value( 'entity', $_REQUEST ));
+    $action = CRM_Utils_String::munge(CRM_Utils_Array::value( 'action', $_REQUEST ));
+    if (!$params) {
+      echo json_encode (array('is_error'=>1,'error_message','invalid json format: ?{"param_with_double_quote":"value"}'));
+      CRM_Utils_System::civiExit( );
+    }
+
+    $params['check_permissions'] = true;
+    $params['version'] = 3;
+    $_REQUEST['json'] = 1;
+    if (!$params['sequential']) {
+      $params['sequential'] = 1;
+    }
+    // trap all fatal errors
+    CRM_Core_Error::setCallback( array( 'CRM_Utils_REST', 'fatal' ) );
+    $result = civicrm_api ($entity, $action,$params);
+
+    CRM_Core_Error::setCallback( );
+
+    echo self::output( $result );
+
     CRM_Utils_System::civiExit( );
+       
   }
 
   static function ajax( ) {
@@ -477,7 +511,7 @@
     // the request has to be sent by an ajax call. First line of protection against csrf
     require_once 'CRM/Core/Config.php';
     $config = CRM_Core_Config::singleton( );
-    if ( false && !$config->debug && ( ! array_key_exists ( 'HTTP_X_REQUESTED_WITH',
+    if ( !$config->debug && ( ! array_key_exists ( 'HTTP_X_REQUESTED_WITH',
       $_SERVER ) ||
       $_SERVER['HTTP_X_REQUESTED_WITH'] != "XMLHttpRequest" ) ) {
         require_once 'api/v3/utils.php';
