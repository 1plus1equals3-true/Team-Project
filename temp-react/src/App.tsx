import React, { useEffect, useRef, useState } from "react";

// --- 1. 타입 및 상수 정의 ---
const CANVAS_WIDTH = 800;
const CANVAS_HEIGHT = 600;
const FPS = 60;

// 적이 이동할 경로 (좌표 x, y)
const WAYPOINTS = [
  { x: 0, y: 100 },
  { x: 700, y: 100 },
  { x: 700, y: 500 },
  { x: 100, y: 500 },
  { x: 100, y: 300 },
  { x: 400, y: 300 }, // 끝점
];

interface Entity {
  id: number;
  x: number;
  y: number;
}

interface Enemy extends Entity {
  wpIndex: number; // 현재 향하고 있는 웨이포인트 인덱스
  hp: number;
  speed: number;
}

interface Tower extends Entity {
  range: number;
  damage: number;
  cooldown: number; // 공격 쿨타임
  lastShotTime: number;
}

interface Projectile extends Entity {
  targetId: number; // 추적할 적 ID
  speed: number;
  damage: number;
}

// --- 2. 메인 컴포넌트 ---
export default function App() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // 리액트 상태는 UI 표시에만 사용 (게임 로직 내부 데이터는 ref로 관리)
  const [money, setMoney] = useState(100);
  const [lives, setLives] = useState(10);
  const [gameOver, setGameOver] = useState(false);

  // 게임 데이터를 Ref로 관리 (리렌더링 방지 및 실시간 업데이트)
  const gameState = useRef({
    enemies: [] as Enemy[],
    towers: [] as Tower[],
    projectiles: [] as Projectile[],
    lastSpawnTime: 0,
    money: 100,
    lives: 10,
    frameCount: 0,
  });

  // 게임 루프 초기화
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let animationId: number;

    const gameLoop = () => {
      if (gameState.current.lives <= 0) {
        setGameOver(true);
        return;
      }

      update();
      draw(ctx);
      animationId = requestAnimationFrame(gameLoop);
    };

    animationId = requestAnimationFrame(gameLoop);

    return () => cancelAnimationFrame(animationId);
  }, []);

  // --- 3. 게임 로직 (Update) ---
  const update = () => {
    const state = gameState.current;
    state.frameCount++;

    // 1) 적 생성 (1초마다)
    if (state.frameCount % 60 === 0) {
      state.enemies.push({
        id: Date.now(),
        x: WAYPOINTS[0].x,
        y: WAYPOINTS[0].y,
        wpIndex: 1,
        hp: 30,
        speed: 2,
      });
    }

    // 2) 적 이동
    state.enemies.forEach((enemy, index) => {
      const target = WAYPOINTS[enemy.wpIndex];
      const dx = target.x - enemy.x;
      const dy = target.y - enemy.y;
      const dist = Math.hypot(dx, dy);

      if (dist < enemy.speed) {
        // 웨이포인트 도착
        enemy.x = target.x;
        enemy.y = target.y;
        enemy.wpIndex++;

        // 최종 목적지 도착 시
        if (enemy.wpIndex >= WAYPOINTS.length) {
          state.enemies.splice(index, 1);
          state.lives--;
          setLives(state.lives); // UI 업데이트
        }
      } else {
        // 이동
        enemy.x += (dx / dist) * enemy.speed;
        enemy.y += (dy / dist) * enemy.speed;
      }
    });

    // 3) 타워 공격 (가장 가까운 적 찾기)
    state.towers.forEach((tower) => {
      if (state.frameCount - tower.lastShotTime < tower.cooldown) return;

      let target: Enemy | null = null;
      let minDist = Infinity;

      state.enemies.forEach((enemy) => {
        const dist = Math.hypot(enemy.x - tower.x, enemy.y - tower.y);
        if (dist <= tower.range && dist < minDist) {
          minDist = dist;
          target = enemy;
        }
      });

      if (target) {
        // 발사체 생성
        state.projectiles.push({
          id: Math.random(),
          x: tower.x,
          y: tower.y,
          targetId: (target as Enemy).id,
          speed: 10,
          damage: tower.damage,
        });
        tower.lastShotTime = state.frameCount;
      }
    });

    // 4) 발사체 이동 및 충돌 처리
    for (let i = state.projectiles.length - 1; i >= 0; i--) {
      const p = state.projectiles[i];
      const target = state.enemies.find((e) => e.id === p.targetId);

      if (!target) {
        state.projectiles.splice(i, 1); // 타겟이 사라지면 총알도 삭제
        continue;
      }

      const dx = target.x - p.x;
      const dy = target.y - p.y;
      const dist = Math.hypot(dx, dy);

      if (dist < p.speed) {
        // 명중
        target.hp -= p.damage;
        state.projectiles.splice(i, 1);

        if (target.hp <= 0) {
          const enemyIndex = state.enemies.indexOf(target);
          if (enemyIndex > -1) {
            state.enemies.splice(enemyIndex, 1);
            state.money += 10;
            setMoney(state.money); // UI 업데이트
          }
        }
      } else {
        p.x += (dx / dist) * p.speed;
        p.y += (dy / dist) * p.speed;
      }
    }
  };

  // --- 4. 그리기 로직 (Draw) ---
  const draw = (ctx: CanvasRenderingContext2D) => {
    // 화면 초기화
    ctx.fillStyle = "#222";
    ctx.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);

    // 경로 그리기
    ctx.strokeStyle = "#555";
    ctx.lineWidth = 20;
    ctx.beginPath();
    ctx.moveTo(WAYPOINTS[0].x, WAYPOINTS[0].y);
    WAYPOINTS.forEach((p) => ctx.lineTo(p.x, p.y));
    ctx.stroke();

    // 타워 그리기 (파란색)
    ctx.fillStyle = "blue";
    gameState.current.towers.forEach((tower) => {
      ctx.beginPath();
      ctx.arc(tower.x, tower.y, 15, 0, Math.PI * 2);
      ctx.fill();

      // 사거리 표시 (선택사항)
      ctx.strokeStyle = "rgba(0, 0, 255, 0.2)";
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.arc(tower.x, tower.y, tower.range, 0, Math.PI * 2);
      ctx.stroke();
    });

    // 적 그리기 (빨간색)
    ctx.fillStyle = "red";
    gameState.current.enemies.forEach((enemy) => {
      ctx.beginPath();
      ctx.arc(enemy.x, enemy.y, 10, 0, Math.PI * 2);
      ctx.fill();

      // 체력바
      ctx.fillStyle = "green";
      ctx.fillRect(enemy.x - 10, enemy.y - 15, 20 * (enemy.hp / 30), 4);
      ctx.fillStyle = "red"; // 다시 적으로 색상 복구
    });

    // 발사체 그리기 (노란색)
    ctx.fillStyle = "yellow";
    gameState.current.projectiles.forEach((p) => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, 3, 0, Math.PI * 2);
      ctx.fill();
    });
  };

  // --- 5. 사용자 인터랙션 ---
  const handleCanvasClick = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (gameOver) return;

    const rect = canvasRef.current!.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    // 타워 건설 비용 확인
    if (gameState.current.money >= 50) {
      gameState.current.towers.push({
        id: Date.now(),
        x,
        y,
        range: 150,
        damage: 10,
        cooldown: 30, // 0.5초 (60프레임 기준)
        lastShotTime: 0,
      });
      gameState.current.money -= 50;
      setMoney(gameState.current.money); // UI 동기화
    } else {
      alert("돈이 부족합니다!");
    }
  };

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: "10px",
        padding: "20px",
        fontFamily: "sans-serif",
      }}
    >
      <h1>🛡️ 심플 디펜스 게임</h1>
      <div
        style={{
          display: "flex",
          gap: "20px",
          fontSize: "18px",
          fontWeight: "bold",
        }}
      >
        <span>💰 Money: {money}</span>
        <span>❤️ Lives: {lives}</span>
      </div>

      <div style={{ position: "relative" }}>
        <canvas
          ref={canvasRef}
          width={CANVAS_WIDTH}
          height={CANVAS_HEIGHT}
          onClick={handleCanvasClick}
          style={{ border: "2px solid #333", cursor: "crosshair" }}
        />
        {gameOver && (
          <div
            style={{
              position: "absolute",
              top: 0,
              left: 0,
              width: "100%",
              height: "100%",
              backgroundColor: "rgba(0,0,0,0.7)",
              color: "white",
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              fontSize: "40px",
            }}
          >
            GAME OVER 💀
          </div>
        )}
      </div>
      <p>맵을 클릭하여 50원을 쓰고 타워를 건설하세요!</p>
    </div>
  );
}
