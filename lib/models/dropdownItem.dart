class DropdownItem{
  int id;
  String descricaodd;

  categoryMap(){
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['descricaodd'] = descricaodd;

    return mapping;
  }
}