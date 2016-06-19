import org.junit.Test;

import java.io.*;
import java.util.*;

/**
 * Created by win8 on 2015/12/4.
 */


public class Merger {
    @Test
    public void mergePlot() throws IOException {
        BufferedReader finalReader =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/Final.tsv")));
        BufferedReader plotReader =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/plot.data")));
        FileOutputStream fout = new FileOutputStream("DataVersion2_WithGenra/raw_plot.data");


        HashMap<String, String> plotMap = new HashMap<>();
        String line;
        while ((line = plotReader.readLine()) != null) {
            line = line.trim();
            String[] kv = line.split("\t");
            plotMap.put(kv[0], kv[1]);
        }

        int numLines = 0;
        while ((line = finalReader.readLine()) != null) {
            line = line.trim();
            String tmp[] = line.split("\t");
            if (plotMap.containsKey(tmp[0])) {
                line += "\t"+plotMap.get(tmp[0]);
                fout.write((line + "\n").getBytes());
                numLines++;
            }
            if (numLines % 100 == 0) { System.out.println(numLines); }
        }
        System.out.println(numLines);
    }

    @Test
    public void getStatistics() throws Exception{
        getStatistics(17);
    }

    private void getStatistics(int index) throws Exception{
        BufferedReader reader =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/Final.tsv")));
        String line;

        HashMap<String, HashMap<String, Integer>> map = new HashMap<>();

        while ((line = reader.readLine()) != null) {
            String col[] = line.split("\t");
            String target = col[index];
            String genre = col[23];
            HashMap<String, Integer> freqMap;
            if (!map.containsKey(target)) {
                freqMap = new HashMap<>();
                freqMap.put(genre, 1);
            } else {
                freqMap = map.get(target);
                int freq = 1;
                if (freqMap.containsKey(genre)) {
                    freq += freqMap.get(genre);
                }
                freqMap.put(genre, freq);
            }
            map.put(target, freqMap);
        }

        for (String key : map.keySet()) {
            System.out.println(key+"\t"+map.get(key).toString());
        }
        System.out.println(map.size());
    }

    @Test
    public void getActor() throws Exception{
        getActorStatistic("Actors_Genra.tsv", "movie_genre.data");
    }

    public void getActorStatistic(String input, String output) throws Exception {
        BufferedReader reader =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/" + input)));
        BufferedReader reader2 =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/Actress_Genra.tsv")));
        FileOutputStream fileOutputStream = new FileOutputStream("DataVersion2_WithGenra/" + output);
        String line;

        HashMap<String, HashMap<String, Integer>> map = new HashMap<>();
        HashMap<String, ArrayList<String>> movie_actorlist = new HashMap<>();

        int numUnknown = 0, numKnown = 0;

        while (true) {
            line = reader.readLine();
            if (line == null) {
                line = reader2.readLine();
            }
            if (line == null) {
                break;
            }
            String col[] = line.split("\t");
            String person = col[0];
            String genre = col[1];
            String movie = col[2];
            HashMap<String, Integer> freqMap;
            if (!map.containsKey(person)) {
                freqMap = new HashMap<>();
                freqMap.put(genre, 1);
            } else {
                freqMap = map.get(person);
                int freq = 1;
                if (freqMap.containsKey(genre)) {
                    freq += freqMap.get(genre);
                }
                freqMap.put(genre, freq);
            }
            map.put(person, freqMap);
            // generate the actor list for each movie
            ArrayList<String> actorList = new ArrayList<>();
            if (movie_actorlist.containsKey(movie)) {
                actorList = movie_actorlist.get(movie);
            }
            actorList.add(person);
            movie_actorlist.put(movie, actorList);
        }

        HashMap <String, String> person_genre = new HashMap<>();
        for (String key : map.keySet()) {
            HashMap<String, Integer> freqMap = map.get(key);
            int maxFreq = 0, secMax = 0;
            String genre = "";
            for (String k : freqMap.keySet()) {
                if (maxFreq < freqMap.get(k)) {
                    secMax = maxFreq;
                    maxFreq = freqMap.get(k);
                    genre = k;
                }
            }
            if (maxFreq > secMax + 0) {
                numKnown++;
                person_genre.put(key, genre);
            } else {
                numUnknown++;
                person_genre.put(key, "unknown");
            }
        }
        System.out.println("known: "+numKnown+" unknown: "+numUnknown);
        System.out.println(person_genre.size()+" actors in "+movie_actorlist.size());

        HashMap <String, String> moive_genre = new HashMap<>();
        for (String movie : movie_actorlist.keySet()) {
            HashMap<String, Integer> statMap = new HashMap<>();
            ArrayList<String> actorList = movie_actorlist.get(movie);

            int maxFreq = 0;
            String maxGenre = "";
            for (String actor : actorList) {
                int freq = 1;
                String genre = person_genre.get(actor);
                if (statMap.containsKey(genre)) {
                    freq += statMap.get(genre);
                }
                if (maxFreq < freq) {
                    maxFreq = freq;
                    maxGenre = genre;
                }
            }
            moive_genre.put(movie, maxGenre);
            fileOutputStream.write((movie + "\t" + maxGenre + "\n").getBytes());
        }
        System.out.println(moive_genre.size());

    }

    @Test
    public void mergeActor() throws Exception{
        BufferedReader reader =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/movie_genre.data")));
        String line;
        HashMap <String, String> map = new HashMap<>();
        while ((line = reader.readLine()) != null) {
            String[] tmp = line.split("\t");
            map.put("\""+tmp[0]+"\"", tmp[1]);
        }
        reader =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/raw4.data")));
        FileOutputStream fileOutputStream = new FileOutputStream("DataVersion2_WithGenra/raw5.data");
        int i = 0;
        int numKnown = 0, numUnknown = 0;
        while ((line = reader.readLine()) != null) {
            String [] tmp = line.split("\t");
            if (i == 0 || map.containsKey(tmp[0])) {
                line += ("\t" + map.get(tmp[0]));
                i++;
                numKnown++;
            } else if (i > 0 && !map.containsKey(tmp[0])) {
                line += ("\t" + "Short");
                numUnknown++;
            }
            fileOutputStream.write((line + "\n").getBytes());
        }
        System.out.println(numKnown+" "+numUnknown);
    }

    @Test
    public void randomSelect() throws Exception{
        BufferedReader reader =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/train_test.data")));
        FileOutputStream train = new FileOutputStream("DataVersion2_WithGenra/train.data");
        FileOutputStream test = new FileOutputStream("DataVersion2_WithGenra/test.data");
        Random r = new Random();
        String line = reader.readLine();
        while ((line = reader.readLine()) != null) {
            if (r.nextInt(10) < 8) {
                train.write((line + "\n").getBytes());
            } else {
                test.write((line + "\n").getBytes());
            }
        }
    }

    @Test
    /**
     * Analysis the text
     * */
    public void getKeyWords() throws Exception{
        BufferedReader reader =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/plot_train.data")));
        BufferedReader reader2 =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/stopwordslist.txt")));
        FileOutputStream fileOutputStream = new FileOutputStream("DataVersion2_WithGenra/keywords.data");
        HashSet<String> stopwords = new HashSet<>();

        String line;
        while ((line = reader2.readLine()) != null) { stopwords.add(line.trim()); }


        HashMap<String, HashMap<String, Integer>> genre_words = new HashMap<>();
        while ((line = reader.readLine()) != null) {
            String attr[] = line.split("\t");
            HashMap<String, Integer> freqMap;
            if (genre_words.containsKey(attr[0])) {
                freqMap = genre_words.get(attr[0]);
            } else {
                freqMap = new HashMap<>();
            }

            String text = attr[1].trim().toLowerCase();
            String[] words = text.split(" ");
            for (String word : words) {
                if (word.length() > 0 && !stopwords.contains(word)) {
                    int freq = 1;
                    if (freqMap.containsKey(word)) {
                        freq += freqMap.get(word);
                    }
                    freqMap.put(word, freq);
                }
            }
            genre_words.put(attr[0], freqMap);
        }

        int top = 25;
        // sort
        for (String key : genre_words.keySet()) {
            ArrayList<Map.Entry<String, Integer>> entryList = new ArrayList<>(genre_words.get(key).entrySet());
            Collections.sort(entryList, (o1, o2) -> o2.getValue().compareTo(o1.getValue()));
            String outputLine = key;
            int total = 0;
            for (int i = 0; i < top; i++) { total += entryList.get(i).getValue(); }
            for (int i = 0; i < top; i++) {
                outputLine += "\t"+entryList.get(i).getKey()+":"+entryList.get(i).getValue()+":"+(entryList.get(i).getValue() * 1.0 / total);
            }
            fileOutputStream.write((outputLine+"\n").getBytes());
        }
    }

    @Test
    public void analysisPlot() throws Exception{

        BufferedReader reader1 =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/train_test.data")));
        BufferedReader reader2 =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/stopwordslist.txt")));
        BufferedReader reader3 =
                new BufferedReader(new InputStreamReader(new FileInputStream("DataVersion2_WithGenra/keywords.data")));
        FileOutputStream fileOutputStream = new FileOutputStream("DataVersion2_WithGenra/train_test_keywords.data");
        HashSet<String> stopwords = new HashSet<>();

        // load the stopwords dic
        String line;
        while ((line = reader2.readLine()) != null) { stopwords.add(line.trim()); }

        // read the key words
        HashMap<String, HashMap<String, Double>> scoreMap = new HashMap<>();
        while((line = reader3.readLine()) != null) {
            String temp[] = line.split("\t");
            String genre = temp[0];
            HashMap<String, Double> keywords = new HashMap<>();
            for (int i = 1; i < temp.length; i++) {
                String temp2[] = temp[i].split(":");
                keywords.put(temp2[0], Double.valueOf(temp2[2]));
            }
            scoreMap.put(genre, keywords);
        }


        while ((line = reader1.readLine()) != null) {
            String plot = line.split("\t")[24].trim().toLowerCase();
            double maxScore = 0.0;
            String maxGenre = "Short";
            for (String genre : scoreMap.keySet()) {
                double score = 0.0;
                HashMap<String, Double> keywords = scoreMap.get(genre);
                for (String word : plot.split(" ")) {
                    if (keywords.containsKey(word)) {
                        score += keywords.get(word);
                    }
                }
                if (score > maxScore) {
                    maxScore = score;
                    maxGenre = genre;
                }
            }
            fileOutputStream.write((line+"\t"+maxGenre+"\n").getBytes());
        }
    }
}
