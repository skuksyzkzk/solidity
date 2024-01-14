// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ERC721 {
    // Token name
    string private _name;
    // Token symbol
    string private _symbol;

    mapping(uint256 => string) private _tokenInfo;
    mapping(uint256 => uint256) private _randomTokenInfo;

    mapping(uint256 => address) private _owners; //각 토큰의 주소

    mapping(address => uint256) private _balances; //주소당 가지고있는 토큰의 갯수

    mapping(uint256 => address) private _tokenApprovals; //토큰 거래 허용 주소

    mapping(address => mapping(address => bool)) private _operatorApprovals; //토큰의 권한정보

    uint256 private totalSupply;
    uint256 private max = 1000;
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address from, address to, uint256 tokenId);
    event ApprovalForAll(address from, address operator, bool approval); //외부 컨트랙트에 이 토큰을 특정 주소가 아닌 누구에가나 옮길 수 있는 그런 권한

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _owners[tokenId];
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    // 토큰의 실제 이미지가 어디에 있는지 그 정보를 가져오는 함수
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        returns (string memory)
    {
        return _tokenInfo[tokenId];
    }

    function randomTokenURI(uint256 tokenId)
        public
        view
        virtual
        returns (uint256)
    {
        return _randomTokenInfo[tokenId];
    }

    //사용자가 어떤 주소에 approve했는지
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        returns (address)
    {
        return _tokenApprovals[tokenId];
    }

    //특정주소가 어떤 operator에게 권한을 넘겨줬는지 확인
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    // 전송하기
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        address owner = _owners[tokenId]; //전송하기전 현재 소유자 권한자 가져오기
        /*
        1. msg.semder 즉 보내는 자와 권한자가 같은지 확인
        2. msg.sender가 권환을 가지고 있는지 확인 isAppr~통해서 
       */
        require(
            (msg.sender == owner || isApprovedForAll(owner, msg.sender)) ||
                getApproved(tokenId) == msg.sender,
            "Not Approved"
        );
        delete _tokenApprovals[tokenId];

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(msg.sender, to, tokenId);
    }

    function mint(
        address to,
        uint256 tokenId,
        string memory url
    ) public {
        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenInfo[tokenId] = url;
        totalSupply += 1;
        emit Transfer(address(0), to, tokenId);
    }

    // 랜덤하게 생성
    function mintRandom(
        address to,
        uint256 tokenId
    ) public {
        _balances[to] += 1;
        _owners[tokenId] = to;
        _randomTokenInfo[tokenId] = random(max);
        // 여기에선 totalSupply max값이 설정되어있다 .
        emit Transfer(address(0), to, tokenId);
    }

    //max 값보다 작아야 하기엥 나누어준다
    function random(uint256 max) internal view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(msg.sender, block.timestamp, max))
            ) % max;
    }

    function burn(uint256 tokenId) public {
        address owner = _owners[tokenId];
        delete _tokenApprovals[tokenId]; // 소유자가 권한을 뺏길수 있기 때문에 제거
        _balances[owner] -= 1;
        delete _owners[tokenId]; //기본값으로 세팅됨으로서 삭제됨
        emit Transfer(owner, address(0), tokenId);
    }

    function transfer(address to, uint256 tokenId) public {
        // 전송하기전에 소유자 정보가 일치하는 지 확인해야한다 .
        require(_owners[tokenId] == msg.sender, "Incorrect Owner");
        // 전송하기전에 권한 삭제
        delete _tokenApprovals[tokenId];

        _balances[msg.sender] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(msg.sender, to, tokenId);
    }

    function approve(address to, uint256 tokenId) public {
        // 권한자는 해당 소유자만 가능하므로, 일치하는 지 확인해야한다 .
        require(_owners[tokenId] == msg.sender, "Incorrect Owner");

        _tokenApprovals[tokenId] = to;

        emit Approval(_owners[tokenId], to, tokenId);
    }

    function setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) public {
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
}
