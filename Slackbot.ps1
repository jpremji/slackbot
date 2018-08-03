#Declare object of the Channel
$MyBot = [PSCustomObject]@{
LastMessage = [decimal] 0
Channel = ‘A212’ #This needs to be set
Token = ‘token-1’ #This needs to be set
Count = '10’
TempTimestamp = [decimal] 0
MyUserName = [string] “MyBot”
MessageChannel = 'W11’
Trigger = ’@’
}

#Creates an array which contains the different channels you have. You can copy $MyBot for each channel.

$BotConfig = @()
$BotConfig += $MyBot

#This is a bad name for this method, however, it gets the latest message’s timestamp.

Function GetTimeStamps ($COnfigData,$messages) {
foreach ($item in $messages.messages) {
if ($item.ts -gt $configdata.lastmessage) {
if ($item.ts -gt $configdata.temptimestamp) {
$configdata.temptimestamp = $item.ts
}
}
}
return $configdata
}

Function GetMessage ($info) {
$url = “https://slack.com/api/groups.history?token=” + $info.token + “&channel=” + $info.channel + “&pretty=1count=10”

$data = Invoke-WebRequest $url -SessionVariable temp

#Convert the data to an object

$returnData = $data.Content | convertfrom-json

return $returnData


}

function NewActionMessage {
[CmdletBinding()]
param(
[Parameter(Mandatory=$true)]
[PSCustomObject]$Object,
[Parameter(Mandatory=$true)]
[PSCustomObject]$Message
)

if ($object.trigger -like $message.message.substring(0,1) -and $message.message.substring(1) -like “help*”) {
SendMessage -token $Object.Token -channel $Object.MessageChannel -opt_username $Object.MyUserName -messagecontent “Welcome to help”
}


}

#This loop will run forever.
do
{ 
#Loop through all your channels declared earlier.
foreach ($Config in $BotConfig) {
#Get all messages for the channel.
$apimessages = GetMessage($Config)
#Store the timestamp for the newest message
$c = GetTimeStamps $Config $apimessages
$Config.TempTimestamp = $c.TempTimestamp
#if the latest message is not set, set it to the last message, therefore nothing will happen on start-up.
if ($Config.LastMessage -lt 0.01) {
$Config.LastMessage = $c.TempTimestamp
}
#Loop through all messages
foreach ($i in $apimessages.messages) {
$text = $I.text
$user = $i.user
$ts = $i.ts
#If the timestamp of the messages pulled from the Slack API are newer than the last message the Bot saw when it last ran
if ($ts -gt $Config.LastMessage -and $user -notlike $Config.MyUserName -and $user -ne $null -and $user -ne “”) {
#Create an object with the message, user.
$TempObject = [PSCustomObject]@{
Message = $text
User = $user
}

$r = NewActionMessage -Object $Config -Message $TempObject 
}
}
#Set the newest message from this API call to the last message received.
$Config.LastMessage = $c.TempTimestamp
Start-Sleep 30
}

} while ($true)