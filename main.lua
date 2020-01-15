--push to prosta biblioteka do obsługi rozdzielczości, która pozwala skupić się na tworzeniu gry ze stałą rozdzielczością.
push = require 'push'
--pozwala nam reprezentować cokolwiek w naszej grze jako kod, zamiast śledzić wiele różnych zmiennych i metod
Class = require 'class'
--wywoływanie  klas
require 'Paddle'
require 'Ball'
--wymiary okna gry
WINDOW_WIDTH=1280
WINDOW_HEIGHT=720

VIRTUAL_WIDTH=432
VIRTUAL_HEIGHT=243
--prędkość paletki
PADDLE_SPEED = 200
--inicjacja gry,funkcja używana przy stacie gry
function love.load()
  
  -- tytuł gry w okienku
  love.window.setTitle('Pong')
  --'seed' aby wywołania losowe były zawsze losowy; os.time uzywa aktualnego czasu ponieważ będzie sie on zmieniał przy kazdym uruchomieniu gry
  math.randomseed(os.time())
  --ustawianie czcionek
  smallFont = love.graphics.newFont('ops.ttf',8)
  largeFont = love.graphics.newFont('ops.ttf',40)
  scoreFont = love.graphics.newFont('ops.ttf',32)
  
  love.graphics.setFont(smallFont)
  love.graphics.setFont(largeFont)
  --inicjue okno z wirtualną rozdzielczością
  push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH, WINDOW_HEIGHT,{
      fullscreen=false,
      resizable=true,
      vsync=true
    })
  -- początkowe punkty graczy
  player1Score = 0
  player2Score = 0
  -- pozycje paletek
  player1 = Paddle(10,30,5,20)
  player2 = Paddle(VIRTUAL_WIDTH - 10,VIRTUAL_HEIGHT - 30,5,20)
  -- pozycja piłki
  ball = Ball(VIRTUAL_WIDTH / 2-2,VIRTUAL_HEIGHT / 2-2,4,4)
  
  --początkowy status gry
  gameState = 'start'
end
--uruchamia każdą ramkę z przekazanym dt, naszą deltą w kilka sekund od ostatniej ramki, którą dostarcza nam LOVE2D
function love.update(dt)
  -- przed naciśnięciem 'enter' ustala kierunek lotu piłki ze względu na to który gracz ostatnio zdobył punkt
  if gameState == 'serve' then
    ball.dy = math.random(-50,50)
    if servingPlayer == 1 then
      ball.dx = math.random(140, 200)
    else
      ball.dx = -math.random(140, 200)
    end  
  
elseif gameState == 'play' then
  --wykrywa kolizję piłki z paletkami, cofając dx, jeśli to prawda, i nieznacznie ją zwiększając, a następnie zmieniając dy w zależności od pozycji 
    if ball:collides(player1) then
      ball.dx = - ball.dx * 1.03
      ball.x = player1.x + 5
      --utrzymuje prędkość w tym samym kierunku, ale losuje ją
      if ball.dy < 0 then
        ball.dy = - math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
    end
    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x -4
      
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
    end
    
--wykrywa kolizję górnej i dolnej granicy ekranu i cofa, jeśli zderzy się z tą granicą
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
    end
    -- -4 na konto rozmiaru piłki
    if ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.y = VIRTUAL_HEIGHT - 4
      ball.dy = -ball.dy
    end
  
  
  -- jesli piłka dotknie lewej lub prawej krawędzi ekranu to wraca na pozycję startową,a odpowiedniemu graczowi nalicza się +1 punkt
    if ball.x <0 then
      servingPlayer = 1
      player2Score = player2Score + 1
      
      -- Jeśli uzykamy wynik 10 koniec gry
      
      if player2Score == 10 then
        winningPlayer = 2
        gameState = 'done'
      else
        gameState = 'serve'
        ball:reset()
      end
     
    end
    
    if ball.x > VIRTUAL_WIDTH then
      servingPlayer = 2
      player1Score = player1Score + 1
      
      if player1Score == 10 then
        winningPlayer = 1
        gameState = 'done'
      else
        gameState = 'serve'
        --ustawia pozycje pilki na srodek ekranu
        ball:reset()
      end
    end
  end
   
  
  -- które przyciski odpowiadają za ruch paletek
  if love.keyboard.isDown('w') then
    player1.dy = - PADDLE_SPEED
   
  elseif love.keyboard.isDown('s') then
    player1.dy = PADDLE_SPEED
  else
    player1.dy = 0
   
  end
  
  if love.keyboard.isDown('up') then
    player2.dy = - PADDLE_SPEED
   
  elseif love.keyboard.isDown('down') then
    player2.dy = PADDLE_SPEED
  else
    player2.dy = 0
   
  end
  
  if gameState == 'play' then
    ball:update(dt)

  end
  player1:update(dt)
  player2:update(dt)
end

   
function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'serve'
    elseif gameState == 'serve' then
      gameState ='play'
    elseif gameState == 'done' then
      gameState = 'serve'
      ball:reset()
      
      --resteujemy punkty do 0
      player1Score=0
      player2Score=0
      
      -- decyzja kto serwuje w następnej rundzie na podstawie ostatniej wygranej
      if winningPlayer == 1 then
        servingPlayer = 2
      else
        servingPlayer = 1
      end

    end
  end
end
--ustawianie koloru i czcionki napisow
function love.draw()
  push:apply('start')
  
  love.graphics.clear(0.1,0.2,0.3,0)
  
  love.graphics.setFont(smallFont)
  
  displayScore()
  
  if gameState=='start' then
    love.graphics.setFont(smallFont)
    love.graphics.printf('Welcome to Pong!',0,10,VIRTUAL_WIDTH,
    'center')
  love.graphics.printf('Press Enter to begin.',0,20,VIRTUAL_WIDTH,
    'center')
  elseif gameState=='serve' then
  love.graphics.setFont(smallFont)
    love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0,10,VIRTUAL_WIDTH,'center')
  love.graphics.printf('Press Enter to serve.',0,20,VIRTUAL_WIDTH,
    'center')
  elseif gameState=='play' then
  elseif gameState=='done' then
  love.graphics.setFont(smallFont)
  love.graphics.printf('Player ' .. tostring(winningPlayer) .. " wins!", 0,10,VIRTUAL_WIDTH,'center')
  love.graphics.printf('Press Enter to restart',0,30,VIRTUAL_WIDTH,
    'center')
  end
 
  
  player1:render()
  player2:render()
  
  ball:render()
  displayFPS()
  

  push:apply('end')
end
-- liczy liczbe klatek na sekunde
function displayFPS()
  love.graphics.setFont(smallFont)
  love.graphics.print('FPS: ' ..tostring(love.timer.getFPS()),10,10)
end
--wyświetla punkty graczy
function displayScore()
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH /2 -50, VIRTUAL_HEIGHT /3)
   love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH /2 +30, VIRTUAL_HEIGHT /3)
end