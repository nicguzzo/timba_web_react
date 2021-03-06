start = programa

programa = _ defprog sentencias: sentencias _ ";" _ defpilas _ pilas: lista_de_pilas? _ "." _  { return {sentencias: sentencias,pilas: pilas}; }

defprog  = "definicion" __ "de" __ "programa" __

defpilas = "ucp" __ "ejecute" __ "con" __ "las" __ "siguientes" __ "cartas" _ ":"

sentencias = head: sentencia tail:( comma s: sentencia  { return s; } )* {
  var result = [];
  [head].concat(tail).forEach(function(element) {
    result.push(element);
  });
  return result;
}

sentencia = operativa / control

operativa  = tomar / depositar / invertir

tomar = tome __ "de" __ pila __  name: nombrepila _ { return {type: 'o', op: 't', name: name,loc: location()}; }

tome = ("tome" (__ "una" (__ "carta")? ) ? )

depositar = deposite __ "en" __ pila __ name: nombrepila _ { return {type: 'o', op: 'd', name: name,loc: location()}; }

deposite = "depositela" / ("deposite" __ carta)

invertir = invierta _ { return {type: 'o', op: 'i',loc: location()}; }

invierta = "inviertala" / ("invierta" __ carta)

nombrepila = name: [a-zA-Z0-9]+ {return name.join("")}

control = seleccion / iterativa

iterativa = "mientras" __ condiciones: condicion __ sentencias: sentencias _ "repita" _ {
  return {type: 'c', control: "w",conditions: condiciones, sentencias: sentencias ,loc: location()};
}

seleccion = "si" __ condiciones:condicion __ on_true: (s:sentencias _ {return s;})? "sino" __ on_false: (s:sentencias _ {return s;})? endif: ( "nada" { return {loc: location()}; } ) __ "mas"  _ {
  return {type: 'c', control: "i",conditions: condiciones, on_true: on_true,on_false: on_false,loc: location(), endif: endif};
}

condicion =  head: condicion_simple tail:( _ op_logico:( "y" / "o" ) _  cs:condicion_simple  { return {cond: cs,op_logico:op_logico};} )*
{
  var result = [];
  [head].concat(tail).forEach(function(element) {
    result.push(element);
  });
  return result;
}

condicion_simple = condicion_pila_vacia / condicion_carta / cond_val_top / cond_val / cond_suit / cond_suit_top

condicion_pila_vacia = pila __ name: nombrepila __ cond: esta_no_esta  __ "vacia" {
  return {type: "empty", name: name, cond: cond};
}

condicion_carta = carta __ condi: esta_no_esta __ "boca" __ "abajo" {
  return {type: "estado", cond: condi};
}

esta_no_esta = n:( "no" __ )? "esta"  {
  var result="e";
  if (n!=null){
    result = "n";
  }
  return result;
}
es_no_es = n:( "no" __ )? "es"  {
  var result="e";
  if (n!=null){
    result = "n";
  }
  return result;
}

relac=       e:"igual"  / n:"distinto"
mayorigual = ("mayor" __"o" __ "igual" ) / ">="
menorigual = ("menor" __"o" __ "igual" ) / "<="
mayoriguala= (mayorigual __ "a" ) / ">="
menoriguala= (menorigual __ "a" ) / "<="
mayorque=    ("mayor" __ "que" ) / ">"
menorque=    ("menor" __ "que") / "<"
iguala=      ("igual" __ "a" )/ "=="
distintode=  ("distinto" __ "de" ) / "!="
relacion=    gte:mayoriguala {return "gte";}/
             lte:menoriguala {return "lte";}/
             eq:iguala {return "eq";}/
             ne:distintode {return "ne";}/
             gt:mayorque {return "gt";}/
             lt:menorque {return "lt";}
relacionT=
  gte:mayorigual {return "gte";}/
  lte:menorigual {return "lte";}/
  eq:"igual" {return "eq";}/
  ne:"distinto" {return "ne";}/
  gt:"mayor" {return "gt";}/
  lt:"menor" {return "lt";}
devalor=  "de" __ "valor"
cond_val=       carta __ cond:es_no_es (__ devalor)? __ rel:relacion __ num:numero  {
  return {type: "valor",cond:cond,rel:rel,num:num};
}

delpalo=        "del" __ "palo"
quetopede=      "que" __ "tope" __ "de"
paloquetopede=  "palo" __ quetopede
valorquetopede= "valor" __ quetopede

cond_suit=  carta __ cond:es_no_es _ delpalo? _ palo:palos  {
  return {type: "palo",cond:cond,palo:palo};
}

cond_suit_top=  carta __  "es"__ "de" __ rel:relac __  paloquetopede  __  pila __ nombre:nombrepila {
  return {type: "palo_tope",rel:rel,name:nombre};
}

cond_val_top=   carta __ cond:es_no_es __ "de" __ rel:relacionT __ valorquetopede __ pila __ nombre:nombrepila {
  return {type: "valor_tope",cond:cond,rel:rel,name:nombre};
}

lista_de_pilas = head: descripcion_de_pila tail:(_ comma _ desc:descripcion_de_pila _ {return desc;} )* {
  var result = [];
  [head].concat(tail).forEach(function(element) {
    result.push(element);
  });
  return result;
}

descripcion_de_pila = pila __ nombre:nombrepila __ contenido:contenido _ {
  return {name: nombre, contenido: contenido};
}

contenido = cont:(vacio / mazo / tiene){return cont;}

tiene = tiene:("tiene" __ cartas: lista_de_cartas {return cartas;}) { return tiene; }

vacio= vacio: ( "no" __ "tiene" __ "cartas" ) { return  {tipo: "vacio"};}

mazo =  "tiene" __ "un" __ "mazo" n:(__ "de" __ m:[0-9]+ __ "cartas" {return m;} )?  _ e:("^" / "_^")? {
  var m=0;
  var s=0;
  if (!(typeof e === 'undefined')){
    if(e=="^"){
      s=1;
    }else{
      if(e=="_^"){
       s=2;
      }
    }
  }
  if (!(typeof n === 'undefined')){
    m=parseInt(n.join(""));
    return {tipo: "mazo_n_cartas", estado: s,n: m};
  }else{
    return {tipo: "mazo_completo", estado: s};
  }

}

lista_de_cartas = head: descripcion_de_carta tail:( _ "-" _ desc:descripcion_de_carta _ {return desc;})* {
  var result = [];
  [head].concat(tail).forEach(function(element) {
    result.push(element);
  });
  return  {tipo: "lista", list:result};
}
descripcion_de_carta= descripcion_de_carta1 / descripcion_de_carta2

descripcion_de_carta1 = num:numero __ "de" __ palo:palos _ inv: "^"? {
  var e=0;
  if (!(typeof inv === 'undefined')){
    e=1;
  }
  return {num: num, palo: palo, estado: e};
}
descripcion_de_carta2 = num:numero _ palo:[bceo] _ inv: "^"? {
  var e=0;
  if (!(typeof inv === 'undefined')){
    e=1;
  }
  var p={"b":"bastos" , "c":"copas" , "e":"espadas" , "o":"oros"};
  return {num: num, palo: p[palo], estado: e};
}

palos = "bastos" / "copas" / "espadas" / "oros"
numero = num: (([1][0-2]) / ([0-7]))  {
  console.log(typeof num)
  console.log("numero: ",num)

  if (typeof num === 'object')
    return parseInt(num.join(""));
  else
    return parseInt(num);
}

pila =  ("la" __ )? "pila"
carta = ("la" __ )? "carta"
paren =  _ [\(\)] _


comma = _ "," _
// optional whitespace
_  = [ \t\r\n]*

// mandatory whitespace
__ = [ \t\r\n]+