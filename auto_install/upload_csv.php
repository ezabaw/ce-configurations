<?php
require_once('create_session.php');
require_once('/opt/kaltura/app/clients/php5/KalturaClient.php');
if (count($argv)<4){
    echo 'Usage:' .__FILE__ .' <partner_id> <service_url> <secret> <uploader>'."\n";
    exit (1);
}
// relevant account user
$partnerId = $argv[1];
$config = new KalturaConfiguration($partnerId);
// URL of the API machine
$config->serviceUrl = $argv[2];
// sha1 secret
$secret = $argv[3];
$uploadedBy = $argv[4];
$userId = null;
$expiry = null;
$privileges = null;
//csv file to use
$csvFileData = '/tmp/kaltura_batch_upload_eagle.csv';
// type here is CSV but can also work with XML
$bulkUploadType = 'bulkUploadCsv.CSV' ;
$client=generate_ks($config->serviceUrl,$partnerId,$secret,$type=KalturaSessionType::ADMIN,$userId=null,$expiry = null,$privileges = null);
// conversion profile to be used
$conversionProfileId = 2;
echo "$conversionProfileId, $csvFileData, $bulkUploadType, $uploadedBy\n";
$results = $client-> bulkUpload ->add($conversionProfileId, $csvFileData, $bulkUploadType, $uploadedBy);
var_dump($results);
?>
