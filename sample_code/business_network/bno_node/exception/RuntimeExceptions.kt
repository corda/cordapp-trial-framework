class PartyNotFoundException(val name : String) : RuntimeException("Party not found: $name") {

}