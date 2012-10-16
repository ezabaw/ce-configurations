<?php
if (count($argv)<2){
    echo __FILE__ . ' <admin_secret>'."\n";
    exit (1);
}
require_once('/opt/kaltura/app/clients/php5/KalturaClient.php');
$admin_partner_id = -2;
$config = new KalturaConfiguration($admin_partner_id);
$config->serviceUrl = 'http://localhost';
$client = new KalturaClient($config);
$expiry = null;
$privileges = null;
$email='jess@kaltura.com';
$name='Kaltura test partner';
$cmsPassword='admin012';
$partner_id=100;
$secret = $argv[1];
try {
        $results = $client->user->loginByLoginId($email,$cmsPassword,$partner_id,$expiry, $privileges);
}
catch (Exception $e) {
    echo 'Caught exception: ',  $e->getMessage(), "\n";
    if ($e->getMessage()==="User was not found" || $e->getMessage()==="Unknown partner_id [$partner_id]"){
        $userId = null;
        $type = KalturaSessionType::ADMIN;
        $ks = $client->session->start($secret, $userId, $type, $admin_partner_id, $expiry, $privileges);
        $client->setKs($ks);
        $partner = new KalturaPartner();
        $partner->website="http://www.kaltura.com";
        $partner->adminName=$name;
        $partner->name=$name;
        $partner->description=" "; //cannot be empty or null
        $partner->adminEmail=$email;
        $results = $client->partner->register($partner, $cmsPassword);
    }
}
?>
