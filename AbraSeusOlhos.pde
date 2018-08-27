//VERSÃO 1.4


import processing.video.*;
import java.awt.Rectangle;

//calibração de brilho e contraste. Use para adaptar a imagem capturada com a cena do vídeo
int brightness = 100;
float contrast = 2;

int eyeLayerCountMax = 140;//quantidade de frames que dura a máscara (mesma duração da cena do corte do olho da moça)
int minEyeSize = 120; //largura mínima para que um olho possa ser considerado válido dentro de uma detecção
boolean videoMode = true;//coloque false se quiser que capture apenas uma foto do olho, true se quiser que capture vídeo
boolean cameraDebugMode = false;//mostra a imagem fonte da câmera


//VARS
Capture cam;
FaceDetection fd;
BrightnessContrastController bc;
PImage img, masked;
Movie video1, video2, video3;
int mode = 0;//0 - afiação da navalha, 1 - corte do olho
int eyeLayerCount = 0;//contagem de permanência do olho capturado
Rectangle det;//informações do recorte do olho detectado

//CODE
void setup() {
  size(1280, 720);
  frameRate(23.98);//sincronizando com o framerate dos vídeos
  
  //posicionamento dos vídeos
  video1 = new Movie(this, "solaminalooplongo.mp4");
  video1.loop();
  
  video2 = new Movie(this, "cortecaoandaluz1.mp4");
  
  video3 = new Movie(this, "olho-difus-alpha1.mp4");
  
  //listagem de câmeras conectadas ao computador
  String[] cameras = Capture.list();
  for (int i = 0; i < cameras.length; i++) {
    println(i + " " + cameras[i]);
  }
  
  //modifique o indice do vetor de cameras conforme a listagem obtida no console
  cam = new Capture(this, 640, 480, cameras[5], 30);//procure usar sempre a resolução 640x480 para exigir menos do computador
  cam.start();
  
  //ativação do reconhecimento do olho via OpenCV
  fd = new FaceDetection(this, cam);
  
  //ativação do filtro de brilho e contraste
  bc = new BrightnessContrastController();
}

void draw() {
  if(cameraDebugMode) {
    image(cam.get(182,164,329,233),0,0);
    if(frameCount % 48 == 0) {
      fd.eyeDetect(cam, minEyeSize,182,164,329,233);
    }
  } else {
  //MODE 0 - exibe loop do vídeo afiando a lâmina e detecta olhos de tempos em tempos
  if (mode == 0) {
    image(video1, 0, 0);
    
    if(frameCount % 48 == 0) {//a cada dois segundos
      if(!videoMode) {
        //MODO FOTO
        
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
          
          eyeLayerCount = 0;
        } else {
          //dispara a detecção paralelamente para não interferir na exibição do vídeo
          thread("detectEyeForPhoto");
        }
      } else {
        //MODO VIDEO
        
        if(det != null) {
          //muda a cena pro modo de corte
          mode = 1;
          video2.play();
          video3.play();
          
          eyeLayerCount = 0;
        } else {
          //dispara a detecção paralelamente para não interferir na exibição do vídeo
          thread("detectEyeForVideo");
        }
      }
    }
  } else {
    //MODE 1 - no modo de corte...
    eyeLayerCount++;
    if(eyeLayerCount < video2.duration()*frameRate) { //enquanto não terminar a cena do corte
      
      if(!videoMode) {
        //MODO FOTO
        
        //exibe a sobreposição do olho capturado durante o trecho do rosto
        
        if(eyeLayerCount < eyeLayerCountMax) {
          img.resize(height/3,height/3);//redimensionamento da imagem capturada
          image(img,width/2 - 25, height/4 + 25);//posicionamento do olho no vídeo
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
        //MODO VIDEO
        
        if(eyeLayerCount < eyeLayerCountMax) {
          img = cam.get(det.x,det.y,det.width,det.height);
          img = bc.nondestructiveShift(img, brightness, contrast);//acerta o brilho e contraste
          //img.filter(GRAY);//ative para deixar preto e branco
          img.resize(height/3,height/3);//redimensionamento da imagem capturada
          image(img,width/2 - 25, height/4 + 25);//posicionamento do olho no vídeo
          masked = get();//obtem a cena já com o olho capturado posicionado
          masked = doAlpha(video3, masked);//aplica a máscara a partir do vídeo 3
          
          image(video2, 0, 0);//exibe a cena do corte
          image(masked, 0, 0);//exibe o olho capturado
        } else {
          image(video2, 0, 0);//exibe a cena do corte
        }
      }
    } else {
      //volta pra cena da afiação
      video2.stop();
      video3.stop();
      video1.jump(0);//reinicia o vídeo do corte
      mode = 0;
      det = null;
      fd.clearDetection();
    }
  }
  }
}

void detectEyeForPhoto() {
  //fd.eyeDoubleDetect(cam, minEyeSize);
  fd.eyeDetect(cam, minEyeSize,182,164,329,233);//tenta detectar a imagem de um olho
}

void detectEyeForVideo() {
  det = fd.eyeDetectRect(cam, minEyeSize,182,164,329,233);
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
  //serve para salvar screenshots do trabalho
  //saveFrame("line-######.png");
}



PImage doAlpha(PImage mImg, PImage vImg) {  
  PImage result = createImage(mImg.width, mImg.height, ARGB);
  color c, d;
  int a, r, g, b;
  
  //só aplica máscara se as dimensões forem iguais
  if(mImg.height != vImg.height || mImg.width != vImg.width) return null; 
  
  //Carrega os pixels da imagem e da máscara
  mImg.loadPixels();
  vImg.loadPixels();
  result.loadPixels();
  
  //loop duplo para passar por cada pixel
  for (int x = 0; x < mImg.width; x++) {
    for (int y = 0; y < mImg.height; y++ ) {
      int loc = x + y*mImg.width;
      
      c = mImg.pixels[loc];//cor do pixel da máscara
      d = vImg.pixels[loc];//cor do pixel da imagem
      
      a = (c >> 16) & 0xFF;//pega o canal r como definição de transparência
      a = 255 - a;//no caso da máscara ser branca, é necessário inverter o valor para que se tenha a transparência 
      r = (d >> 16) & 0xFF;
      g = (d >> 8) & 0xFF;
      b = d & 0xFF;
      
      result.pixels[loc] = color(r, g, b, a);
    }
  }

  //faz o update para fixar as mudanças de pixel
  result.updatePixels();
  return(result);
}
