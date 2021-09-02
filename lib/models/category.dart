class Category{
  int id;
  String nome;
  String descricao;
  int dropdownInfo;

  categoryMap(){
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['nome'] = nome;
    mapping['descricao'] = descricao;
    mapping['dropdownInfo'] = dropdownInfo;

    return mapping;
  }
}