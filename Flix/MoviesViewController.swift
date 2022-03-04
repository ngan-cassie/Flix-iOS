//
//  MoviesViewController.swift
//  Flix
//
//  Created by Hieu Ngan Nguyen on 2/23/22.
//

import UIKit
import AlamofireImage

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies = [[String:Any]]() // [[<type of key>:<type of value>]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        /* Create a URL: unwrap the optional URL with a !
        in case not a valid URL -> app crash to fix it */
        let url = URL(string: "https://api.themoviedb.org/3/movie/297762/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&page=1")!
        // create the URLRequest object - information about the request
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        // create the session object
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        // send request to the server
        let task = session.dataTask(with: request) { (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                 // Get the array of movies
                 /* Deserialize the JSON Data to a generic object
                  -> Downcast the resulting obj to a dict */
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    print(dataDictionary)
                     // Store the movies as an array of dictionaries
                     self.movies = dataDictionary["results"] as! [[String:Any]]
                 self.tableView.reloadData()

             }
        }
        // Tasks are created in a suspended state. To initiate the task, you must call it’s resume() method.
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String // casting: tell what the type
        let synopsis = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.synopsisLabel.text = synopsis
        
        let baseUrl = "https://image.tmdb.org/t/p/w185"
        let posterPath = movie["poster_path"] as! String
        let posterUrl = URL(string: baseUrl + posterPath)
        cell.posterView.af.setImage(withURL: posterUrl!)
        return cell
     
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destination.
//         Pass the selected object to the new view controller.
        
        // Find the selected movie - which one is tapped on
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let movie = movies[indexPath.row]
        
        // Pass the selected movie to the details view controller
        let detailsViewController = segue.destination as! MovieDetailsViewController // ! because it might return generic view controller
        detailsViewController.movie = movie
        
        tableView.deselectRow(at: indexPath, animated: true) // screen isn't displayed as selected when comes back to main screen
    }
    

}
