import gab.opencv.*;
import java.awt.Rectangle;


class FaceDetection {
  private OpenCV opencv;
  private Rectangle[] faces,eyes,noses;
  private int size, faceSelected, faceSize, eyeSelected, eyeSize;

  public PImage focusImg;
  public PVector rEyeCenter, lEyeCenter, nose;
  
  public FaceDetection(PApplet context, Capture came) {
    //instancia o objeto CV
    opencv = new OpenCV(context, came.width, came.height);
  }
  
  //a detecção de uma face exige 3 etapas: detectar que há uma face, que há 2 olhos e um nariz. Do contrário, nada será detectado
  public void detect(Capture came) {
    faceSelected = -1;
    focusImg = null;//esvazia a imagem primeiro
     
    //ETAPA 1 - detecção pela face
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
    opencv.loadImage(came);
    faces = opencv.detect();
    
    //Se encontrar faces
    if (faces != null && faces.length > 0) {
      //for (int i = 0; i < faces.length; i++) {
      //  strokeWeight(2);
      //  stroke(255,0,0);
      //  noFill();
      //  rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
      //}
      
      faceSize = 0;
      //escolhe a maior face detectada (a mais próxima)
      for(int i = 0;i<faces.length;i++) {
        println("face "+i+": "+faces[i].width+" "+faces[i].height);
        if(faces[i].width > 150){
          if(faces[i].width > faceSize) {
            faceSelected = i;
            faceSize = faces[i].width;
          }
        }
      }
      //faceSelected = (int)random(0,faces.length);
      if(faceSelected >= 0) {
        faceSelected = constrain(faceSelected,0,faces.length-1);
        size = faces[faceSelected].width;
        
        //cria a imagem foco
        focusImg = came.get(faces[faceSelected].x - size/2, faces[faceSelected].y - size/2, size*2, size*2);
        focusImg.resize(height,height);
      }
    }
    
    //ETAPA 2 - detecção pelos olhos
    //if(focusImg != null) {  
    //  opencv.loadCascade(OpenCV.CASCADE_EYE);
    //  opencv.loadImage(focusImg);
    //  eyes = opencv.detect();
    //  if(eyes != null && eyes.length > 1) {
    //    //olhos foram detectados
    //    lEyeCenter = new PVector(eyes[0].x + eyes[0].width/2, eyes[0].y + eyes[0].height/2);
    //    rEyeCenter = new PVector(lEyeCenter.x, lEyeCenter.y);
        
    //    if(eyes[1].x > eyes[0].x) {
    //      rEyeCenter.x = eyes[1].x + eyes[1].width/2;
    //      rEyeCenter.y = eyes[1].y + eyes[1].width/2;
    //    } else {
    //      lEyeCenter.x = eyes[1].x + eyes[1].width/2;
    //      lEyeCenter.y = eyes[1].y + eyes[1].width/2;
    //    }
    //  } else {
    //    focusImg = null;//esvazia a imagem para não prosseguir
    //  }
    //} 
    
    ////ETAPA 3 - detecção pelos olhos
    //if(focusImg != null) {
    //  //tenta descobrir onde está o nariz
    //  opencv.loadCascade(OpenCV.CASCADE_NOSE); 
    //  opencv.loadImage(focusImg);
    //  noses = opencv.detect();
    //  if(noses != null && noses.length > 0) {
    //    //narizes foram detectados
    //    nose = new PVector(noses[0].x, noses[0].y);
    //  } else {
    //    focusImg = null;//esvazia a imagem para não prosseguir
    //  }
    //}
  }
  
  public void eyeDetect(Capture came, int minSize) {
    eyeSelected = -1;
    focusImg = null;//esvazia a imagem primeiro
    
    //ETAPA 1 - detecção pela face
    opencv.loadCascade(OpenCV.CASCADE_EYE);
    opencv.loadImage(came);
    eyes = opencv.detect();
    
    //Se encontrar faces
    if (eyes != null && eyes.length > 0) {
      
      //for (int i = 0; i < eyes.length; i++) {
      //  strokeWeight(2);
      //  stroke(255,0,0);
      //  noFill();
      //  rect(eyes[i].x, eyes[i].y, eyes[i].width, eyes[i].height);
      //}
      
      eyeSize = 0;
      //escolhe a maior face detectada (a mais próxima)
      for(int i = 0;i<eyes.length;i++) {
        
        if(eyes[i].width > minSize && eyes[i].width > eyeSize) {
          eyeSelected = i;
          eyeSize = eyes[i].width;
        }
      }
      
      //faceSelected = (int)random(0,faces.length);
      if(eyeSelected >= 0) {
        eyeSelected = constrain(eyeSelected,0,eyes.length-1);
        size = eyes[eyeSelected].width;
        
        //cria a imagem foco
        focusImg = came.get(eyes[eyeSelected].x - size/2, eyes[eyeSelected].y - size/2, size*2, size*2);
        focusImg.resize(height,height);
      }
    }
  }
  
  public Rectangle eyeDetectRect(Capture came, int minSize) {
    eyeSelected = -1;
    focusImg = null;//esvazia a imagem primeiro
    
    //ETAPA 1 - detecção pela face
    opencv.loadCascade(OpenCV.CASCADE_EYE);
    opencv.loadImage(came);
    eyes = opencv.detect();
    
    //Se encontrar olhos
    if (eyes != null && eyes.length > 0) {
      
      //for (int i = 0; i < eyes.length; i++) {
      //  strokeWeight(2);
      //  stroke(255,0,0);
      //  noFill();
      //  rect(eyes[i].x, eyes[i].y, eyes[i].width, eyes[i].height);
      //}
      
      eyeSize = 0;
      //escolhe a maior face detectada (a mais próxima)
      for(int i = 0;i<eyes.length;i++) {
        
        if(eyes[i].width > minSize && eyes[i].width > eyeSize) {
          eyeSelected = i;
          eyeSize = eyes[i].width;
        }
      }
      
      //faceSelected = (int)random(0,faces.length);
      if(eyeSelected >= 0) {
        size = eyes[eyeSelected].width;
        return(new Rectangle(eyes[eyeSelected].x - size/2, eyes[eyeSelected].y - size/2, size*2, size*2));
      }
    }
    return null;
  }
  
  public void eyeDetectSecondPass(PImage img, int minSize) {
    eyeSelected = -1;
    focusImg = null;//esvazia a imagem primeiro
    
    //ETAPA 1 - detecção pela face
    opencv.loadCascade(OpenCV.CASCADE_EYE);
    opencv.loadImage(img);
    eyes = opencv.detect();
    
    //Se encontrar olhos
    if (eyes != null && eyes.length > 0) {
      
      eyeSize = 0;
      //escolhe a maior face detectada (a mais próxima)
      for(int i = 0;i<eyes.length;i++) {
        
        if(eyes[i].width > minSize && eyes[i].width > eyeSize) { //<>//
          eyeSelected = i;
          eyeSize = eyes[i].width;
        }
      }
      
      if(eyeSelected >= 0) {
        eyeSelected = constrain(eyeSelected,0,eyes.length-1);
        size = eyes[eyeSelected].width;
        
        //cria a imagem foco
        focusImg = img.get();
      }
    }
  }
}
