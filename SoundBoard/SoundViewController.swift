//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Carlos Velasquez on 13/05/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    
    @IBOutlet weak var grabarButton: UIButton!
    
    
    @IBOutlet weak var tiempoLabel: UILabel!
    @IBOutlet weak var reproducirButton: UIButton!
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var volumenSlider: UISlider!
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    var timer: Timer?
    var totalDuracion: TimeInterval = 0 // Variable para almacenar la duración total mientras se graba

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        // Configuramos el slider de volumen
               volumenSlider.minimumValue = 0.0
               volumenSlider.maximumValue = 1.0
               volumenSlider.value = 0.5 // Valor inicial del volumen
    }
    
    
    func configurarGrabacion(){
       do{
           let session = AVAudioSession.sharedInstance()
           try session.setCategory(AVAudioSession.Category.playAndRecord, mode:AVAudioSession.Mode.default, options: [])
           try session.overrideOutputAudioPort(.speaker)
           try session.setActive(true)


           let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).first!
           let pathComponents = [basePath,"audio.m4a"]
           audioURL = NSURL.fileURL(withPathComponents: pathComponents)!


           print("*****************")
           print(audioURL!)
           print("*****************")


           var settings:[String:AnyObject] = [:]
           settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
           settings[AVSampleRateKey] = 44100.0 as AnyObject?
           settings[AVNumberOfChannelsKey] = 2 as AnyObject?


           grabarAudio = try AVAudioRecorder(url:audioURL!, settings: settings)
           grabarAudio!.prepareToRecord()
       }catch let error as NSError{
           print(error)
       }
    }
    


    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
                    // Detener la grabación y el temporizador
                    grabarAudio?.stop()
                    timer?.invalidate()
                    grabarButton.setTitle("GRABAR", for: .normal)
                    reproducirButton.isEnabled = true
                    agregarButton.isEnabled = true
                } else {
                    // Iniciar la grabación y el temporizador
                    grabarAudio?.record()
                    grabarButton.setTitle("DETENER", for: .normal)
                    reproducirButton.isEnabled = false
                    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempo), userInfo: nil, repeats: true)
                }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
           try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
           reproducirAudio!.play()
           print("Reproduciendo")
        }catch{}
    }
    
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf:audioURL!)! as Data
        grabacion.duracion = formatearTiempo(tiempo: totalDuracion)

        print("Nombre: \(grabacion.nombre ?? "")")
        print("Duración: \(grabacion.duracion ?? "")")
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    @objc func actualizarTiempo() {
          // Actualizar el label de tiempo con la duración transcurrida
        let currentTime = grabarAudio?.currentTime ?? 0 // Obtener el tiempo actual de la grabación
        totalDuracion += 1.0 // Añadir un segundo a la duración total cada vez que se actualiza el tiempo
        tiempoLabel.text = formatearTiempo(tiempo: totalDuracion)
      }
    func formatearTiempo(tiempo: TimeInterval) -> String {
          let minutos = Int(tiempo) / 60
          let segundos = Int(tiempo) % 60
          return String(format: "%02d:%02d", minutos, segundos)
      }
    @IBAction func volumenChanged(_ sender: UISlider) {
        reproducirAudio?.volume = sender.value

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
