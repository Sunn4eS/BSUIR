import EarTrainingCard  from './EarTrainingCard';
import PlayPracticeCard  from './PlayPracticeCard';
import FingeringTestCard from './FingeringTestCard';
import PlayFingeringCard from './PlayFingeringCard';
import ComboFingeringCard from './ComboFingeringCard';

export default function TaskCard({ card, onAnswer, readOnly }) {
  const type = card?.task?.type || card?.cardData?.type || card?.type;

  if (type === 'EAR_TRAINING') {
    return <EarTrainingCard card={card} onAnswer={onAnswer} readOnly={readOnly} />;
  }

  if (type === 'PLAY_PRACTICE') {
    return <PlayPracticeCard card={card} onAnswer={onAnswer} readOnly={readOnly} />;
  }

  if (type === 'FINGERING_TEST') {
    return <FingeringTestCard card={card} onAnswer={onAnswer} readOnly={readOnly} />;
  }

  if (type === 'PLAY_FINGERING') {
    return <PlayFingeringCard card={card} onAnswer={onAnswer} readOnly={readOnly} />;
  }

  if (type === 'COMBO_FINGERING') {
    return <ComboFingeringCard card={card} onAnswer={onAnswer} readOnly={readOnly} />;
  }

  return (
    <div className="task-card" style={{ textAlign: 'center', color: 'var(--color-text-muted)' }}>
      <p>Неизвестный тип задания: {type}</p>
    </div>
  );
}
