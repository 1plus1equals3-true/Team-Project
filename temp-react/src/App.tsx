import React, { useState } from "react";
// ⭐️ axios 대신 우리가 만든 api 인스턴스 임포트
import api from "./api/api";

const App = () => {
  // api.ts에 baseURL을 설정했으므로 경로는 뒷부분만 적으면 됩니다.
  const AUTH_URL = "/api/auth";
  const USER_URL = "/api/users";

  const [regData, setRegData] = useState({
    userid: "",
    pwd: "",
    username: "",
    birth: "",
  });

  const [loginData, setLoginData] = useState({
    userid: "",
    pwd: "",
  });

  const [userInfo, setUserInfo] = useState<any>(null);

  const handleRegChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setRegData({ ...regData, [e.target.name]: e.target.value });
  };

  const handleLoginChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setLoginData({ ...loginData, [e.target.name]: e.target.value });
  };

  const handleRegister = async () => {
    try {
      const response = await api.post(`${AUTH_URL}/register`, regData);
      alert("성공: " + response.data);
    } catch (error: any) {
      alert("실패: " + (error.response?.data?.message || "에러 발생"));
    }
  };

  const handleLogin = async () => {
    try {
      await api.post(`${AUTH_URL}/login`, loginData);
      alert("로그인 성공! 10초 뒤 '내 정보 조회'를 눌러보세요 (자동 재발급 테스트)");
    } catch (error: any) {
      alert("로그인 실패: " + (error.response?.data || error.message));
    }
  };

  const handleLogout = async () => {
    try {
      await api.post(`${AUTH_URL}/logout`);
      setUserInfo(null);
      alert("로그아웃 성공");
    } catch (error: any) {
      alert("로그아웃 실패");
    }
  };

  // ⭐️ [핵심 테스트]
  // 10초 뒤 토큰이 만료되었을 때 이 버튼을 누르면:
  // 1. 401 에러 발생 -> 2. 인터셉터가 감지 -> 3. /reissue 요청 -> 4. 성공 시 다시 조회
  // 사용자는 에러를 못 느끼고 정보가 뜹니다.
  const handleGetInfo = async () => {
    try {
      const response = await api.get(`${USER_URL}/me`);
      setUserInfo(response.data);
      alert("조회 성공! (만료되었다면 자동으로 갱신되었을 겁니다)");
    } catch (error: any) {
      // 리프레시 토큰까지 만료된 경우 여기로 옵니다.
      console.error(error);
    }
  };

  return (
    <div style={{ padding: "50px", fontFamily: "sans-serif" }}>
      <h1>🛡️ 자동 재발급 테스트 (Interceptor)</h1>

      <div style={{ display: "flex", gap: "30px", flexWrap: "wrap" }}>
        {/* 회원가입 폼 */}
        <div style={{ border: "1px solid #ccc", padding: "20px", borderRadius: "10px", width: "300px" }}>
          <h2>1. 회원가입</h2>
          <input name="userid" placeholder="아이디" value={regData.userid} onChange={handleRegChange} style={inputStyle} />
          <input name="pwd" type="password" placeholder="비밀번호" value={regData.pwd} onChange={handleRegChange} style={inputStyle} />
          <input name="username" placeholder="닉네임" value={regData.username} onChange={handleRegChange} style={inputStyle} />
          <input name="birth" type="date" value={regData.birth} onChange={handleRegChange} style={inputStyle} />
          <button onClick={handleRegister} style={btnStyle}>가입하기</button>
        </div>

        {/* 로그인/로그아웃 */}
        <div style={{ border: "1px solid #007bff", padding: "20px", borderRadius: "10px", width: "300px" }}>
          <h2>2. 로그인</h2>
          <input name="userid" placeholder="아이디" value={loginData.userid} onChange={handleLoginChange} style={inputStyle} />
          <input name="pwd" type="password" placeholder="비밀번호" value={loginData.pwd} onChange={handleLoginChange} style={inputStyle} />
          <div style={{ display: "flex", gap: "5px" }}>
            <button onClick={handleLogin} style={{ ...btnStyle, background: "#007bff", color: "white" }}>로그인</button>
            <button onClick={handleLogout} style={{ ...btnStyle, background: "#dc3545", color: "white" }}>로그아웃</button>
          </div>
        </div>

        {/* 정보 조회 */}
        <div style={{ border: "1px solid #28a745", padding: "20px", borderRadius: "10px", width: "300px" }}>
          <h2>3. 정보 조회 (자동 갱신)</h2>
          <p>로그인 10초 후 눌러보세요.<br/>따로 재발급 버튼을 누르지 않아도 됩니다.</p>
          <button onClick={handleGetInfo} style={{ ...btnStyle, background: "#6c757d", color: "white" }}>
            내 정보 조회
          </button>

          {userInfo && (
            <div style={{ marginTop: "20px", background: "#666", padding: "10px", borderRadius: "5px" }}>
              <p>👤 {userInfo.username}</p>
              <p>💰 {userInfo.gold} G</p>
              <p>💎 {userInfo.diamond} D</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const inputStyle = { display: "block", width: "90%", margin: "10px 0", padding: "8px" };
const btnStyle = { padding: "8px 15px", cursor: "pointer", border: "none", borderRadius: "4px", fontWeight: "bold" };

export default App;