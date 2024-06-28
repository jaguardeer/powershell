function Send-WolPacket {
    param(
        [Parameter(Mandatory=$true)] [String] $targetMac,
        [Parameter(Mandatory=$true)] [String] $targetIp
    )

    $ErrorActionPreference = "Stop"

    # create packet: FFFFFFFFFFFF and then 16x repetitions of target MAC

    $preamble = [Byte[]] 0xFF * 6
    $macBytes = [byte[]] -split ($targetMac -replace '..', '0x$& ')
	$packet = $preamble + $macBytes * 16


    # send packet

    # config remote endpoint
    $dstIp = [System.Net.IPAddress]::Parse($targetIp)
    $dstPort = [Int] 7
    $targetEp = [System.Net.IpEndpoint]::new($dstIp, $dstPort)
    # config local socket
    $sockType = [System.Net.Sockets.SocketType]::Dgram
    $sockProto = [System.Net.Sockets.ProtocolType]::Udp
    $sock = [System.Net.Sockets.Socket]::new($sockType, $sockProto)
    # connect and send
    $sock.Connect($targetEp)
    $sock.Send($packet)
}