import macrox.Macrox;
import haxe.macro.Expr;

class Test {

  static function main() {
    var a = 7;
    // Macrox.trace(x);
    trace("start");
    var c : Dynamic = Macrox.test();
    
    var a = function(msg, a:Dynamic, b:Dynamic){
      if (haxe.Serializer.run(a) != haxe.Serializer.run(b)) {
        trace(msg + " failed");
        trace(a);
        trace(b);
      }
    };

    var idx = 0;

    a("int_expr"      , c[idx++] , 10);
    a("int"      , c[idx++] , 2);
    a("float"    , c[idx++] , 2.2);
    a("string"   , c[idx++] , "string");
    a("null"     , c[idx++] , null);
    a("object" , c[idx++] , {a: "a"});
    a("function 1" , c[idx++]() , 7);
    a("function 2" , c[idx++]() , 8);
  }    

}
