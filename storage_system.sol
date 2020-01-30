pragma solidity ^0.4.19;
contract storagesys
{
    uint sizeperuser = 10000; //ユーザーあたりの共有するサイズ
    uint alluser = 0; //ユーザー数
    
    //各ユーザーの情報を格納する構造体
    struct userInfo{
        address user; //ユーザーのアドレス
        uint256 owncap; //そのユーザのストレージの残り
        uint256 usecap; //そのユーザーがアップロード出来る残り
    }
    userInfo[] public UserInfo;
    
    //各ファイルの情報を格納する構造体    
    struct fileInfo{
        address user; //送信者のアドレス
        string hash; //ファイルのハッシュ値
        uint256 size; //ファイルのサイズ
        bool status; //ファイルの状態 登録ならtrue 削除ならfalse
        address owner1; //ファイルの所有者1
        address owner2; //ファイルの所有者2
    }
    fileInfo[] public FileInfo;
    
   function adduser()  public returns (string)//ユーザー情報の追加
   {
       for(uint i=0;i<alluser;i++) //既存ユーザーによる追加を拒否
       {
           require(UserInfo[i].user != msg.sender);
       }
       UserInfo.length++;
       UserInfo[UserInfo.length-1].user = msg.sender; //構造体に送信者のアドレスを格納
       UserInfo[UserInfo.length-1].owncap = sizeperuser; //構造体にそのユーザのストレージの残りを格納
       UserInfo[UserInfo.length-1].usecap = sizeperuser; //構造体にそのユーザーがアップロード出来る残りを格納
       alluser++;
       
       return "正常に完了しました";
   }
   function addfile (string _hash,uint256 _size) public returns (string)//ファイルの追加情報を入力
   {
       //ユーザー登録されたアドレスであるか確認
       for (uint i=0;i<alluser;i++)
       {
           if(keccak256(UserInfo[i].user) == keccak256(msg.sender))
           {
               break;
           }
       }
       require(UserInfo[i].user == msg.sender);
       require(UserInfo[i].usecap >= _size);
       UserInfo[i].usecap = UserInfo[i].usecap - _size; //そのユーザーがアップロード出来る残りを減算
     
       FileInfo.length++;
       FileInfo[FileInfo.length-1].user = msg.sender; //構造体に送信者のアドレスを格納
       FileInfo[FileInfo.length-1].hash = _hash; //構造体にファイルのハッシュ値を格納
       FileInfo[FileInfo.length-1].size = _size; //構造体にファイルのサイズを格納
       FileInfo[FileInfo.length-1].status = true; //構造体にファイルの状態(有効)を格納
       UserInfo.length++;
       
       //ユーザのストレージの空き容量を降順にソート
       for (i=0; i< alluser; i++)      
       {
          for (uint j=i+1; j<alluser; j++) 
          {
              if (UserInfo[i].owncap < UserInfo[j].owncap) 
              {
                  UserInfo[alluser].user = UserInfo[i].user;
                  UserInfo[alluser].owncap = UserInfo[i].owncap;
                  UserInfo[alluser].usecap = UserInfo[i].usecap;
                  
                  UserInfo[i].user = UserInfo[j].user;
                  UserInfo[i].owncap = UserInfo[j].owncap;
                  UserInfo[i].usecap = UserInfo[j].usecap;
                  
                  UserInfo[j].user = UserInfo[alluser].user;
                  UserInfo[j].owncap = UserInfo[alluser].owncap;
                  UserInfo[j].usecap = UserInfo[alluser].usecap;
                  
              }
          }
      }
      UserInfo.length--;
      
      //ファイルの追加者本人を除く上位２名のストレージの空き容量を減算
      if(keccak256(UserInfo[0].user) == keccak256(msg.sender))
       {
           FileInfo[FileInfo.length-1].owner1 = UserInfo[1].user;
           require(UserInfo[1].owncap >= _size);
           UserInfo[1].owncap =  UserInfo[1].owncap - _size;
           FileInfo[FileInfo.length-1].owner2 = UserInfo[2].user;
           require(UserInfo[2].owncap >= _size);
           UserInfo[2].owncap =  UserInfo[2].owncap - _size;
       }
       else if(keccak256(UserInfo[1].user) == keccak256(msg.sender))
       {
           FileInfo[FileInfo.length-1].owner1 = UserInfo[0].user;
           require(UserInfo[0].owncap >= _size);
           UserInfo[0].owncap =  UserInfo[0].owncap - _size;
           FileInfo[FileInfo.length-1].owner2 = UserInfo[2].user;
           require(UserInfo[2].owncap >= _size);           
           UserInfo[2].owncap =  UserInfo[2].owncap - _size;
       }
       else
       {
           FileInfo[FileInfo.length-1].owner1 = UserInfo[0].user;
           require(UserInfo[0].owncap >= _size);
           UserInfo[0].owncap =  UserInfo[0].owncap - _size;
           FileInfo[FileInfo.length-1].owner2 = UserInfo[1].user;
           require(UserInfo[1].owncap >= _size);
           UserInfo[1].owncap =  UserInfo[1].owncap - _size;
       }
       
       return "正常に完了しました";
   }
   function delfile (string _hash,uint256 _size) public returns (string)//ファイルの削除情報を入力
   {
       //ユーザー登録されたアドレスであるか確認
       for (uint i=0;i<alluser;i++)
       {
           if(keccak256(UserInfo[i].user) == keccak256(msg.sender))
           {
               break;
           }
       }
       require(UserInfo[i].user == msg.sender); 
       UserInfo[i].usecap = UserInfo[i].usecap + _size; //そのユーザーがアップロード出来る残りを加算

       FileInfo.length++;
       FileInfo[FileInfo.length-1].user = msg.sender; //構造体に送信者のアドレスを格納
       FileInfo[FileInfo.length-1].hash = _hash; //構造体にファイルのハッシュ値を格納
       FileInfo[FileInfo.length-1].size = _size; //構造体にファイルのサイズを格納
       for(i=0;i<FileInfo.length;i++)
       {
           if(keccak256(FileInfo[i].hash) == keccak256(_hash))
           {
               break;
           }
       }
       
       //ファイルの追加で減算されたユーザーの空き容量を加算
       for(uint k=0;k<alluser;k++)
       {
           if(keccak256(FileInfo[i].owner1) == keccak256(UserInfo[k].user))
           {
               FileInfo[FileInfo.length-1].owner1 = UserInfo[k].user;
               UserInfo[k].owncap = UserInfo[k].owncap + _size;
           }
       }
       for(k=0;k<alluser;k++)
       {
           if(keccak256(FileInfo[i].owner2) == keccak256(UserInfo[k].user))
           {
               FileInfo[FileInfo.length-1].owner2 = UserInfo[k].user;
               UserInfo[k].owncap = UserInfo[k].owncap + _size;
           }
       }
       return "正常に完了しました";
   }
}