import processing.video.*;

//calibração
int brightness = 100;
float contrast = 2;
//TODO vetor de posições para variar a posição do olho

//VARS
Capture cam;
FaceDetection fd;
BrightnessContrastController bc;
PImage img, mask;
Movie video1, video2, video3;
int mode = 0;//0 - afiação da navalha, 1 - corte do olho
int eyeLayerCount = 0;//contagem de permanência do olho capturado
boolean v3playing;

//CODE
void setup() {
  size(1280, 720);
  frameRate(23.98);//sincronizando com o framerate dos vídeos
  
  //posicionamento dos vídeos
  video1 = new Movie(this, "afiandolamina.mp4");
  video1.loop();
  
  video2 = new Movie(this, "cortecaoandaluz.mp4");
  
  video3 = new Movie(this, "navalha-RGB.mp4");
  // video3.loop();
  
  
  //ativação da câmera
  String[] cameras = Capture.list();
  for (int i = 0; i < cameras.length; i++) {
    println(i + " " + cameras[i]);
  }
  cam = new Capture(this, 640, 480, cameras[1], 30);
  //cam = new Capture(this, 640, 480, cameras[0], 30);
  cam.start();
  
  
  //ativação do reconhecimento do olho via OpenCV
  fd = new FaceDetection(this, cam);
  
  bc = new BrightnessContrastController();
  
  mask = loadImage("eyemask.png");
}

void draw() {
 
  if (mode == 0) {
    image(video1, 0, 0);
    //image(video3, 0, 0);
    
    if(frameCount % 12 == 0) {//a cada meio segundo
      fd.eyeDetect(cam, 100);//tenta detectar a imagem de um olho
      
      //se detectar um olho
      if(fd.focusImg != null) {
        img = fd.focusImg.get();//armazena a imagem
        img = bc.nondestructiveShift(img, brightness, contrast);//acerta o brilho e contraste
        img.filter(GRAY);
        mask.resize(img.width,img.height);
        
        //muda a cena pro modo de corte
        mode = 1;
        video2.play();
        
        v3playing = false;
        eyeLayerCount = 0;
      }
    }
    
  } else {
    //no modo de corte...
    if(video2.time() < video2.duration()) { //enquanto não terminar a cena do corte
      image(video2, 0, 0);//exibe a cena do corte
      
      //exibe a sobreposição do olho capturado durante o trecho do rosto
      eyeLayerCount++;
      if(eyeLayerCount < 87) {
        
        img.mask(mask);
        image(img,width/2-20,height/4+10);
      }
      if(eyeLayerCount == 130) {
        img.resize(height,height);
        mask.resize(img.width,img.height);
      }
      if(eyeLayerCount > 130) {
        img.mask(mask);
        image(img,250,-100);
      }
      
      //TODO exibir a sobreposição da camada da lâmina
      if(video2.time() > 5.17) {
        if(!v3playing) {
          video3.play();
          v3playing = true;
        }
        
        if(v3playing) {
          image(doAlpha(video3),0,0);
        }
      }
    } else {
      //volta pra cena da afiação
      video2.stop();
      video3.stop();
      video1.jump(0);
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
  println(video3.get(mouseX,mouseY));
}

PImage doAlpha(PImage vImg) {  
  float threshold = 3;
  PImage result = createImage(vImg.width, vImg.height, ARGB);
  
  // We are going to look at both image's pixels
  vImg.loadPixels();
  result.loadPixels();
  
  for (int x = 0; x < vImg.width; x++) {
    for (int y = 0; y < vImg.height; y++ ) {
      int loc = x + y*vImg.width;
      
      if (brightness(vImg.pixels[loc]) < threshold) {
        result.pixels[loc]  = color(255, 0);
      } else {
        result.pixels[loc]  = vImg.pixels[loc];
      }
    }
  }

  // We changed the pixels in destination
  result.updatePixels();
  // Display the destination
  //image(destination,0,0);
  return(result);
}