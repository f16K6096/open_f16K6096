pragma solidity ^0.4.19;
contract storagesys
{
    uint sizeperuser = 10000; //���[�U�[������̋��L����T�C�Y
    uint alluser = 0; //���[�U�[��
    
    //�e���[�U�[�̏����i�[����\����
    struct userInfo{
        address user; //���[�U�[�̃A�h���X
        uint256 owncap; //���̃��[�U�̃X�g���[�W�̎c��
        uint256 usecap; //���̃��[�U�[���A�b�v���[�h�o����c��
    }
    userInfo[] public UserInfo;
    
    //�e�t�@�C���̏����i�[����\����    
    struct fileInfo{
        address user; //���M�҂̃A�h���X
        string hash; //�t�@�C���̃n�b�V���l
        uint256 size; //�t�@�C���̃T�C�Y
        bool status; //�t�@�C���̏�� �o�^�Ȃ�true �폜�Ȃ�false
        address owner1; //�t�@�C���̏��L��1
        address owner2; //�t�@�C���̏��L��2
    }
    fileInfo[] public FileInfo;
    
   function adduser()  public returns (string)//���[�U�[���̒ǉ�
   {
       for(uint i=0;i<alluser;i++) //�������[�U�[�ɂ��ǉ�������
       {
           require(UserInfo[i].user != msg.sender);
       }
       UserInfo.length++;
       UserInfo[UserInfo.length-1].user = msg.sender; //�\���̂ɑ��M�҂̃A�h���X���i�[
       UserInfo[UserInfo.length-1].owncap = sizeperuser; //�\���̂ɂ��̃��[�U�̃X�g���[�W�̎c����i�[
       UserInfo[UserInfo.length-1].usecap = sizeperuser; //�\���̂ɂ��̃��[�U�[���A�b�v���[�h�o����c����i�[
       alluser++;
       
       return "����Ɋ������܂���";
   }
   function addfile (string _hash,uint256 _size) public returns (string)//�t�@�C���̒ǉ��������
   {
       //���[�U�[�o�^���ꂽ�A�h���X�ł��邩�m�F
       for (uint i=0;i<alluser;i++)
       {
           if(keccak256(UserInfo[i].user) == keccak256(msg.sender))
           {
               break;
           }
       }
       require(UserInfo[i].user == msg.sender);
       require(UserInfo[i].usecap >= _size);
       UserInfo[i].usecap = UserInfo[i].usecap - _size; //���̃��[�U�[���A�b�v���[�h�o����c������Z
     
       FileInfo.length++;
       FileInfo[FileInfo.length-1].user = msg.sender; //�\���̂ɑ��M�҂̃A�h���X���i�[
       FileInfo[FileInfo.length-1].hash = _hash; //�\���̂Ƀt�@�C���̃n�b�V���l���i�[
       FileInfo[FileInfo.length-1].size = _size; //�\���̂Ƀt�@�C���̃T�C�Y���i�[
       FileInfo[FileInfo.length-1].status = true; //�\���̂Ƀt�@�C���̏��(�L��)���i�[
       UserInfo.length++;
       
       //���[�U�̃X�g���[�W�̋󂫗e�ʂ��~���Ƀ\�[�g
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
      
      //�t�@�C���̒ǉ��Җ{�l��������ʂQ���̃X�g���[�W�̋󂫗e�ʂ����Z
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
       
       return "����Ɋ������܂���";
   }
   function delfile (string _hash,uint256 _size) public returns (string)//�t�@�C���̍폜�������
   {
       //���[�U�[�o�^���ꂽ�A�h���X�ł��邩�m�F
       for (uint i=0;i<alluser;i++)
       {
           if(keccak256(UserInfo[i].user) == keccak256(msg.sender))
           {
               break;
           }
       }
       require(UserInfo[i].user == msg.sender); 
       UserInfo[i].usecap = UserInfo[i].usecap + _size; //���̃��[�U�[���A�b�v���[�h�o����c������Z

       FileInfo.length++;
       FileInfo[FileInfo.length-1].user = msg.sender; //�\���̂ɑ��M�҂̃A�h���X���i�[
       FileInfo[FileInfo.length-1].hash = _hash; //�\���̂Ƀt�@�C���̃n�b�V���l���i�[
       FileInfo[FileInfo.length-1].size = _size; //�\���̂Ƀt�@�C���̃T�C�Y���i�[
       for(i=0;i<FileInfo.length;i++)
       {
           if(keccak256(FileInfo[i].hash) == keccak256(_hash))
           {
               break;
           }
       }
       
       //�t�@�C���̒ǉ��Ō��Z���ꂽ���[�U�[�̋󂫗e�ʂ����Z
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
       return "����Ɋ������܂���";
   }
}