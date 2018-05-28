import processing.video.*;

//calibração
int brightness = 100;
float contrast = 2;
//TODO vetor de posições para variar a posição do olho

//VARS
Capture cam;
FaceDetection fd;
BrightnessContrastController bc;
PImage img, masked;
Movie video1, video2, video3;
int mode = 0;//0 - afiação da navalha, 1 - corte do olho
int eyeLayerCount = 0;//contagem de permanência do olho capturado
boolean v3playing;

//CODE
void setup() {
  size(1280, 720);
  frameRate(23.98);//sincronizando com o framerate dos vídeos
  
  //posicionamento dos vídeos
  video1 = new Movie(this, "somenteLamina.mp4");
  video1.loop();
  
  video2 = new Movie(this, "cortecaoandaluz.mp4");
  
  video3 = new Movie(this, "olho-difus-alpha.mp4");
  
  //ativação da câmera
  String[] cameras = Capture.list();
  for (int i = 0; i < cameras.length; i++) {
    println(i + " " + cameras[i]);
  }
  cam = new Capture(this, 640, 480, cameras[5], 30);
  //cam = new Capture(this, 640, 480, cameras[0], 30);
  cam.start();
  
  
  //ativação do reconhecimento do olho via OpenCV
  fd = new FaceDetection(this, cam);
  
  bc = new BrightnessContrastController();
  
  //mask = loadImage("eyemask.png");
}

void draw() {
  //MODE 0 - exibe loop do vídeo afiando a lâmina e detecta olhos de tempos em tempos
  if (mode == 0) {
    image(video1, 0, 0);
    
    if(frameCount % 48 == 0) {//a cada dois segundos
      fd.eyeDetect(cam, 90);//tenta detectar a imagem de um olho
      
      //se detectar um olho
      if(fd.focusImg != null) {
        img = fd.focusImg.get();//armazena a imagem
        img = bc.nondestructiveShift(img, brightness, contrast);//acerta o brilho e contraste
        //img.filter(GRAY);//ative para deixar preto e branco
        img.resize(height/4,height/4);
        
        //muda a cena pro modo de corte
        mode = 1;
        video2.play();
        video3.play();
        
        v3playing = false;
        eyeLayerCount = 0;
      }
    }
  
  } else {
    //MODE 1 - no modo de corte...
    if(video2.time() < video2.duration()) { //enquanto não terminar a cena do corte
      
      
      //exibe a sobreposição do olho capturado durante o trecho do rosto
      eyeLayerCount++;
      if(eyeLayerCount < 60) {println(eyeLayerCount);
        img.resize(height/3,height/3);
        image(img,width/2 - 25, height/4 + 25);
        masked = get();//obtem a cena já com o olho capturado posicionado
        masked = doAlpha(video3, masked);//aplica a máscara a partir do vídeo 3
        
        image(video2, 0, 0);//exibe a cena do corte
        image(masked, 0, 0);//exibe o olho capturado
      }
      else
      {
        image(video2, 0, 0);//exibe a cena do corte
      }
    } else {
      //volta pra cena da afiação
      video2.stop();
      video3.stop();
      video1.jump(0);//reinicia o vídeo do corte
      mode = 0;
    }
  }
  
}



//atualiza a leitura dos vídeos
void movieEvent(Movie m) {
  m.read();
}

//atualiza a fonte da câmera
void captureEvent(Capture cam) {
  cam.read();
}

void mouseClicked() {
  saveFrame("line-######.png");
}

PImage doAlpha(PImage mImg, PImage vImg) {  
  PImage result = createImage(mImg.width, mImg.height, ARGB);
  color c, d;
  int a, r, g, b;
  
  // We are going to look at both image's pixels
  mImg.loadPixels();
  vImg.loadPixels();
  result.loadPixels();
  
  for (int x = 0; x < mImg.width; x++) {
    for (int y = 0; y < mImg.height; y++ ) {
      int loc = x + y*mImg.width;
      
      c = mImg.pixels[loc];
      d = vImg.pixels[loc];
      
      a = (c >> 16) & 0xFF;//pega o canal r como definição de transparência
      a = 255 - a;
      r = (d >> 16) & 0xFF;
      g = (d >> 8) & 0xFF;
      b = d & 0xFF;
      
      result.pixels[loc] = color(r, g, b, a);
    }
  }

  // We changed the pixels in destination
  result.updatePixels();
  // Display the destination
  //image(destination,0,0);
  return(result);
}