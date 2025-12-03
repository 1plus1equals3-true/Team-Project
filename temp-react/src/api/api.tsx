import axios from "axios";

// 1. Axios 인스턴스 생성
const api = axios.create({
  baseURL: "http://localhost:8070", // 백엔드 주소
  withCredentials: true, // 쿠키 전송 필수
});

// 2. 응답 인터셉터 설정 (Response Interceptor)
api.interceptors.response.use(
  (response) => {
    // 요청이 성공하면 그대로 응답 반환
    return response;
  },
  async (error) => {
    // 에러 발생 시 처리
    const originalRequest = error.config;

    // 에러 상태가 401(Unauthorized)이고, 아직 재시도를 안 했다면?
    // (백엔드 JwtAuthenticationEntryPoint에서 401을 리턴하도록 설정했으므로 401 체크)
    if (error.response && error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true; // 무한 루프 방지용 플래그

      try {
        // 1. 리프레시 토큰으로 액세스 토큰 재발급 요청
        // (쿠키에 리프레시 토큰이 있으므로 별도 데이터 전송 불필요)
        await api.post("/api/auth/reissue");

        // 2. 재발급 성공 시, 원래 실패했던 요청을 다시 시도
        return api(originalRequest);
      } catch (reissueError) {
        // 3. 재발급도 실패하면? (리프레시 토큰 만료) -> 로그아웃 처리
        alert("세션이 만료되었습니다. 다시 로그인해주세요.");
        
        // 로그아웃 요청 (백엔드 쿠키 삭제)
        try {
            await api.post("/api/auth/logout");
        } catch (e) {
            console.error(e);
        }
        
        // 홈으로 튕겨내기 (또는 로그인 페이지로 이동)
        window.location.href = "/"; 
        
        return Promise.reject(reissueError);
      }
    }

    // 401 에러가 아니거나 재시도 실패 시 에러 그대로 반환
    return Promise.reject(error);
  }
);

export default api;