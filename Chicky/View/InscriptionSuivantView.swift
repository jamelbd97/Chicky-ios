//
//  InscriptionSuivantView.swift
//  Chicky
//
//  Created by Jamel & Maher on 22/11/2021.
//

import UIKit

class InscriptionSuivantView: UIViewController {
    
    // VAR
    let utilisateurViewModel = UtilisateurViewModel()
    var utilisateur: Utilisateur?
    
    // WIDGET
    @IBOutlet weak var nomTextField: UITextField!
    @IBOutlet weak var prenomTextField: UITextField!
    @IBOutlet weak var dateNaissanceTextField: UITextField!
    @IBOutlet weak var sexeTextField: UITextField!
    
    // PROTOCOLS
    
    // LIFECYCLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ConnexionView
        destination.email = sender as? String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // METHODS
    func goToLogin(email: String?) {
        self.performSegue(withIdentifier: "connexionSegue", sender: email)
    }
    
    // ACTIONS
    @IBAction func inscriptionButton(_ sender: Any) {
        
        if (nomTextField.text == "") {
            self.present(Alert.makeAlert(titre: "Erreur", message: "Veuillez saisir votre nom"), animated: true)
            return
        }
        
        if (prenomTextField.text == "") {
            self.present(Alert.makeAlert(titre: "Erreur", message: "Veuillez saisir votre prenom"), animated: true)
            return
        }
        
        if (dateNaissanceTextField.text == "") {
            self.present(Alert.makeAlert(titre: "Erreur", message: "Veuillez saisir votre date de naissance"), animated: true)
            return
        }
        
        if (sexeTextField.text == "") {
            self.present(Alert.makeAlert(titre: "Erreur", message: "Veuillez saisir votre sexe"), animated: true)
            return
        }
        
        utilisateur?.idPhoto = ""
        utilisateur?.score = 0
        utilisateur?.bio = ""
        utilisateur?.nom = nomTextField.text
        utilisateur?.prenom = prenomTextField.text
        utilisateur?.dateNaissance = Date()
        utilisateur?.sexe = true
        
        // START Spinnder
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        utilisateurViewModel.inscription(utilisateur: utilisateur!, completed: { (success) in
            // STOP Spinner
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
            
            if success {
                
                //self.present(Alert.makeAlert(titre: "Succés", message: "Votre compte a été bien creé veuillez confirmer votre email."), animated: true)
                
                let alert = UIAlertController(title: "Succés", message: "Votre compte a été bien creé veuillez confirmer votre email.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    self.goToLogin(email: self.utilisateur?.email)
                }
                alert.addAction(action)
                self.present(alert, animated: true)
            } else {
                self.present(Alert.makeAlert(titre: "Erreur d'inscription", message: "Veuillez verifier si le compte existe deja."), animated: true)
            }
            
            // STOP Spinner
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        })
    }
    
}