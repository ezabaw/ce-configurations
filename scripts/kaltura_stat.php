<?php
#!/bin/bash
#**************************************
#	Kaltura
#**************************************
# This provides usage statistics about the Kaltura install

require_once '/opt/kaltura/web/content/clientlibs/php5/KalturaClient.php';
require_once '/opt/kaltura/web/content/clientlibs/php5/KalturaPlugins/KalturaSystemPartnerClientPlugin.php';


echo "Username: ";
$loginId= trim(fgets(STDIN));
echo "\nPassword: ";
system('stty -echo');
$password = trim(fgets(STDIN));
system('stty echo');
echo "\nIs this Falcon or higher? (y/n) ";
$version = trim(fgets(STDIN));
$serviceUrl ='http://localhost';
$partnerID=-2;


# Create an administrator session
$kalturaConfig = new KalturaConfiguration($partnerID);
$kalturaConfig->serviceUrl = $serviceUrl;
$kalturaClient = new KalturaClient($kalturaConfig);
$kalturaService = new KalturaSystemPartnerService($kalturaClient);
$ks = $kalturaClient->user->loginbyloginid($loginId, $password);
$kalturaClient->setKs($ks);

# Grand totals
$totalEntries = 0;
$totalFlavors = 0;
$totalUsers = 0;
$totalContrib = 0;
$allFlavors = array();

# Get a list of all publishers
$kresult = $kalturaService->listAction();

# CSV format for the output
echo "\nName,Publisher ID, Publisher Admin Email, Entry Count, Flavor Count, KMC User Count,KMS User Count,Unique Contributors, Total Users\n\n";

# Process each publisher
foreach ($kresult->objects as $publisher){

        $publisherId=$publisher->id;
        # Skip service accounts
        if ($publisherId < 100) continue;

        #Determine the admin account for the publisher
        $adminSecret=$publisher->adminSecret;
        $adminUserId=$publisher->adminUserId;

        try{
                # Create a new session with the admin of the publisher
                $kalturaConfig = new KalturaConfiguration($publisherId);
                $kalturaConfig->serviceUrl = $serviceUrl;
                $kalturaClient = new KalturaClient($kalturaConfig);
                $ks = $kalturaClient->session->start ($adminSecret, $adminUserId, KalturaSessionType::ADMIN,$publisherId);
                $kalturaClient->setKs($ks);
                # Statistics
                $entryCount = $kalturaClient->media->count();
                $pubUsers = $kalturaClient->user->listAction();
                $userCount = $pubUsers->totalCount;
                $KMCUserCount = 0;
			
                # Count all users who have the property is_admin=1 (KMCusers)
				# then subtract from totalCount to obtain the amount of KMS users
                foreach ($pubUsers->objects as $i){
                        if($i->isAdmin) ++$KMCUserCount;
                }
				$KMSUserCount = $userCount - $KMCUserCount;
				
                # Obtain a complete list of entries to obtain unique creators
				# Falcon puts this in creatorId whereas Eagle uses "userId"
				$pubEntries = $kalturaClient->media->listAction();
                $creators = array();
				foreach ($pubEntries->objects as $i){
						if ($version == "y")$creators[] = $i->creatorId;
						else $creators[] = $i->userId;
				}
				# Eliminate duplicates from the creator array
				$creatorsUnique = array_unique($creators);
				$contribUsers = count($creatorsUnique);

                # Obtain flavor count and array of all flavors in this publisher
                $flavors = $kalturaClient->flavorParams->listAction();
				foreach ($flavors->objects as $i){
					$allFlavors[] = $i->id;
				}
                $flavorCount  = $flavors->totalCount;
                # Add to grand totals
                $totalEntries = $totalEntries + $entryCount;
                $totalFlavors = $totalFlavors + $flavorCount;
                $totalUsers = $totalUsers + $userCount;
                $totalContrib= $totalContrib + $contribUsers;
			
                echo "$publisher->name,$publisher->adminEmail,$publisherId,$entryCount,$flavorCount,$KMCUserCount,$KMSUserCount,$contribUsers,$userCount\n";

        }catch (Exception $e) {

                # This is to catch publishers that have been deleted or other random exceptions
				# a nicer way to do this would be to catch each type of exception and print why however
				# testing has shown that any publisher you can access properly will show statistics, if not, something is either
				# wrong and nothing will show or you can't access that publisher at all no matter what you try
        }
}
$uniqueTotalFlavors = count(array_unique($allFlavors));
echo "\nTotal Entries $totalEntries\n";
echo "Total Unique Flavors $uniqueTotalFlavors\n";
echo "Total Users $totalUsers\n";
echo "Total Unique Contributing Users $totalContrib\n";

?>
