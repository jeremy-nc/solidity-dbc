//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

enum UserOutcomeTypes {
    UserNoOutcome,
    UserSuccessOutcome,
    UserNotFoundOutcome
}

contract UserOutcome {
    UserOutcomeTypes typee = UserOutcomeTypes.UserNoOutcome;
    
    function isType(UserOutcomeTypes t) public view
    returns (bool) {
        return typee == t;
    }
}

contract UserSuccessOutcome is UserOutcome {
    
    int public result;

    constructor(int r) {
        result = r;
        typee = UserOutcomeTypes.UserSuccessOutcome;
    }

}

contract UserNotFoundOutcome is UserOutcome {
    
    string public message;

    constructor(string memory m) {
        message = m;
        typee = UserOutcomeTypes.UserNotFoundOutcome;
    }

}

library UsersLib {
    struct User {
       string name;
    }
}

contract Users {

    constructor() { }

    function getUser(int id) public
    returns (UserOutcome result) {
        if (id < 0) {
            return new UserNotFoundOutcome("User not found for ID < 0");
        } else {
            return new UserSuccessOutcome(id);
        }
    }

}

enum EventOutcomeTypes {
    NoOutcome,
    CreatedSuccess,
    CreatedFail,
    Success,
    NotFound
}

contract EventOutcome {
    EventOutcomeTypes typee = EventOutcomeTypes.NoOutcome;
    
    function isType(EventOutcomeTypes t) public view
    returns (bool) {
        return typee == t;
    }
}

contract EventCreatedSuccessOutcome is EventOutcome {
    
    uint256 public result;

    constructor(uint256 r) {
        result = r;
        typee = EventOutcomeTypes.CreatedSuccess;
    }

}

contract EventCreatedFailOutcome is EventOutcome {
    
    string public message;

    constructor(string memory m) {
        message = m;
        typee = EventOutcomeTypes.CreatedFail;
    }

}

contract EventSuccessOutcome is EventOutcome {
    
    EventLib.Event private res;

    constructor(EventLib.Event memory evt) {
        res = evt;
        typee = EventOutcomeTypes.Success;
    }

    function result() public view
    returns (uint256, address, string memory) {
        return (res.id, res.owner, res.name);
    }

}

contract EventNotFoundOutcome is EventOutcome {
    
    string public message;

    constructor(string memory m) {
        message = m;
        typee = EventOutcomeTypes.NotFound;
    }

}

library EventLib {

    struct Event {
        uint256 id;
        address owner;
        string name;
        // uint256 qty; - TODO - capacity on tickets for event
    }

}

contract Events {

    uint256 private count = 0;

    mapping(uint256 => EventLib.Event) private events;

    constructor() { }

    function createEvent(string calldata name) public
    returns (EventOutcome){
        // TODO - safe count
        uint256 eventId = count++;
        
        EventLib.Event memory newEvent;
        newEvent.id = eventId;
        newEvent.owner = msg.sender;
        newEvent.name = name;

        events[eventId] = newEvent;

        return new EventCreatedSuccessOutcome(eventId);
    }
    
    function getEvent(uint256 eventId) public
    returns (EventOutcome){
        EventLib.Event memory evt = events[eventId];
        
        if (evt.owner == address(0x0))
            return new EventNotFoundOutcome("Event by that ID doesnt exist");

        return new EventSuccessOutcome(evt);
    }

}

library TicketLib {

    struct Ticket {
        uint256 id;
        uint256 eventId;
    }

}

contract Tickets {

    mapping(uint256 => TicketLib.Ticket) private tickets;

    constructor() { }

}

contract TicketsController {

    Users users = new Users();
    Events events = new Events();

    constructor() { }

    function getUser(int id) public 
    returns (int userId) { // should be: string memory name, and all the attr of the user
        UserOutcome result = users.getUser(id);

        // TODO - cast, based on type?
        if (result.isType(UserOutcomeTypes.UserNotFoundOutcome)) 
            revert(UserNotFoundOutcome(address(result)).message());

        // TODO - destructure result
        int user = UserSuccessOutcome(address(result)).result();
        return user;
    }

    function createEvent(string calldata name) public
    returns (uint256 eventId) {
        // TOOD - validate caller / ACLs
        EventOutcome result = events.createEvent(name);

        if (result.isType(EventOutcomeTypes.CreatedFail)) 
            revert(EventCreatedFailOutcome(address(result)).message());

        uint256 eId = EventCreatedSuccessOutcome(address(result)).result();
        return eId;
    }
    
    function getEvent(uint256 evtId) public
    returns (uint256 eventId) {
        EventOutcome result = events.getEvent(evtId);

        if (result.isType(EventOutcomeTypes.NotFound)) 
            revert(EventNotFoundOutcome(address(result)).message());

        (uint256 id, address owner, string memory name) = EventSuccessOutcome(address(result)).result();
        return id;
    }

}