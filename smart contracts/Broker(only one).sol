pragma solidity ^0.4.16 ;
import "./NtuaToken.sol" ;

contract Broker {
	
	NtuaToken Ntua = NtuaToken(0xd50972d2b1747e6277134d29db36e88dacf12844) ;
	//TYPES
	//struct for the information of every sensor
	struct sensor {
	    address seller ;
	    uint8 sensorType ;
	    uint price ;
	    uint32 startTime ;
	    uint16 frequency ;          //measurements per hour => frequency*3600 measurements per second
	    int32 latitude ;
	    int32 longitude ;
	    string url ;
	}
	
	struct transaction {
	    uint sensorID ;
	    uint32 fromTime ;           //converted in unix timestamp
	    uint32 toTime ;
	    uint amount ;
	}
    
	//EVENTS
	event SensorCreated(address indexed seller, uint32 indexed sensorID,uint8 sensorType, uint price, uint32 startTime, uint16 frequency, int32 latitude, int32 longtitude,string url) ;
    event SensorChangedSeller(uint32 sensorID, address seller) ;
    event SensorChangedPrice(uint32 sensorID, uint price) ;
    event SensorChangedUrl(uint32 sensorID, string url) ;
    event CompletedTransaction(uint32 transID, address indexed buyer, uint32 indexed sensorID, uint32 fromTime, uint32 toTime, uint amount) ;
    
	//METHODS
	//Constructor
	function Broker() {
	    id = 1 ;
	    transID = 1 ;
	}
	
	//functions for the sellers
	function createSensor(address seller1, uint8 type1, uint price1, uint32 startTime1, uint16 frequency1, int32 latitude1, int32 longitude1, string url1) external {
	    sensors[id].seller = seller1 ;
	    sensors[id].sensorType = type1 ;
	    sensors[id].price = price1 ;
	    sensors[id].startTime = startTime1 ;
	    sensors[id].frequency = frequency1 ;
	    sensors[id].latitude = latitude1 ;
	    sensors[id].longitude = longitude1 ;
	    sensors[id].url = url1 ;
	    SensorCreated(seller1, id, type1, price1, startTime1, frequency1, latitude1, longitude1, url1) ;
	    id++ ;          //give unique id identifier
	}
	
	function changeSensorSeller(uint32 sensorID1, address seller1) external {
	    require(msg.sender == sensors[sensorID1].seller) ;
	    sensors[sensorID1].seller = seller1 ;
	    SensorChangedSeller(sensorID1,seller1) ;
	}
	
	function changeSensorPrice(uint32 sensorID1, uint price1) external {
	    require(msg.sender == sensors[sensorID1].seller) ;
	    sensors[sensorID1].price = price1 ;
	    SensorChangedPrice(sensorID1,price1) ;
	}
	
	function changeSensorUrl(uint32 sensorID1, string url1) external {
	    require(msg.sender == sensors[sensorID1].seller) ;
	    sensors[sensorID1].url = url1 ;
	    SensorChangedUrl(sensorID1,url1) ;
	}
	
	//functions for the buyers
	function buyData(uint32 sensorID, uint32 fromTime, uint32 toTime) external {
	    address seller = sensors[sensorID].seller ;
	    require(fromTime >= sensors[sensorID].startTime) ;
	    uint32 interval = toTime - fromTime ;
	    require(interval >= 3600) ;     //no less than 1 hour
	    uint amount = interval * sensors[sensorID].frequency * sensors[sensorID].price / 3600 ;
	    
	    Ntua.brokerTransferFrom(msg.sender, seller, amount) ;
	    
        transactions[msg.sender].push(transaction(sensorID, fromTime, toTime, amount)) ;
	    CompletedTransaction(transID, msg.sender, sensorID, fromTime, toTime, amount) ;
	    transID ++ ;
	}
	
	//FIELDS
	//auto generated SensorID
	uint32 id ;
	//auto generated TransactionID
	uint32 transID ;
	//all the sensors in the system (sensorID => sensor)
	mapping(uint => sensor) sensors ;
	//all the transactions completed (buyer => sensorID)
	mapping(address => transaction[]) transactions ;
}