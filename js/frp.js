// this.$foo = {}
// $foo.bus = $({})

// localStorage.userName = 'rigidus';

// $foo.userName = function(){
//   return localStorage.userName
// }

// $foo.message = function(){
//   return 'Привет, ' + $foo.userName() + '!'
// }

// $foo._userName_listening = false
// $foo.userName = function() {
//   if (!this._userName_listening) {
//     window.addEventListener('storage', function(event) {
//       // alert('zzz');
//       if(event.key !== 'userName') { return }
//       $foo.bus.trigger('changed:$foo.userName')
//     }, false)
//     this._userName_listening = true
//   }
//   return localStorage.userName
// }

// $foo._message_listening = false
// $foo.message = function() {
//   if (!this._message_listening) {
//     $foo.bus.on( 'changed:$foo.userName', function() {
//       $foo.bus.trigger('changed:$foo.message')
//     })
//     this._message_listening = true
//   }
//   return 'Привет, ' + $foo.userName() + '!'
// }

// $foo._sayHello_listening = false
// $foo.sayHello = function(){
//   if(!this._sayHello_listening){
//     $foo.bus.on('changed:$foo.message', function() {
//       $foo.sayHello()
//     })
//     this._message_listening = true
//   }
//   $("#frp").html($foo.message());
// }

// $foo.start = function() {
//   $foo.sayHello();
// }

// $(function() {
//   $foo.start();
// });

// $(function () {
//   setTimeout(function () {
//     localStorage.userName = localStorage.userName + ' rigidus ';
//     // alert(localStorage.userName);
//   }, 1000);
// });
